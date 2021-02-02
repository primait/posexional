defmodule Posexional.Field.Field do
  @moduledoc """
  this module represent a single field in a row of a positional file
  """
  use Timex
  alias Posexional.Field
  alias Posexional.Field.Value

  defstruct [:name, :field_value, :type, :opts]

  @type field_type() ::
          :id
          | :binary_id
          | :integer
          | :float
          | :boolean
          | :string
          | :binary
          | :array
          | :list
          | :decimal
          | :date
          | :time
          | :datetime
          | :naive_datetime
          | :utc_datetime

  @type t :: %__MODULE__{}

  @spec new(atom, integer, field_type, Keyword.t()) :: %Posexional.Field.Field{}
  def new(name, type, size, opts \\ []) do
    value = Value.new(name, size, opts)

    %__MODULE__{name: name, field_value: value, type: type, opts: opts}
  end

  @spec parse(String.t(), field_type, Keyword.t()) ::
          integer()
          | String.t()
          | float()
          | Date.t()
          | Time.t()
          | NaiveDateTime.t()
          | DateTime.t()
          | boolean()
          | list()
          | any()

  defp parse(value_str, type, opts)

  defp parse(value_str, _type, %{parser: parser}) when is_function(parser, 1) do
    parser.(value_str)
  rescue
    _ ->
      raise ArgumentError, "The provided parser could not parse value #{value_str}"
  end

  defp parse(value_str, type, %{parser: parser}) when is_function(parser, 2) do
    parser.(value_str, type)
  rescue
    _ ->
      raise ArgumentError, "The provided parser could not parse value #{value_str} of type #{type}"
  end

  defp parse(value_str, :id, opts), do: parse(value_str, :integer, opts)
  defp parse(value_str, :binary_id, _opts), do: value_str

  defp parse(value_str, :integer, opts) do
    base = Map.get(opts, :base, 10)

    case Integer.parse(value_str, base) do
      {int, ""} -> int
      _ -> raise ArgumentError, "#{value_str} is not a valid integer. Provide option :base should it not be on 10."
    end
  end

  defp parse(value_str, :float, _opts) do
    case Float.parse(value_str) do
      {float, ""} -> float
      _ -> raise ArgumentError, "#{value_str} is not a valid float number."
    end
  end

  defp parse("true", :boolean, _opts), do: true
  defp parse("false", :boolean, _opts), do: false
  defp parse(value_str, :boolean, _opts), do: raise(ArgumentError, "#{value_str} is not a valid boolean.")
  defp parse(value_str, :string, _opts), do: value_str
  defp parse(value_str, :binary, _opts), do: value_str
  defp parse(value_str, :array, opts), do: parse(value_str, :list, opts)
  defp parse(value_str, :decimal, opts), do: parse(value_str, :float, opts)

  defp parse(value_str, :list, %{separator: separator}) when is_binary(separator) do
    value_str
    |> String.split(separator)
    |> Enum.reject(&(&1 == ""))
  end

  defp parse(_value_str, :list, _opts), do: raise(ArgumentError, "Provide a :separator option")

  defp parse(value_str, :date, %{format_in: format_in} = _opts) do
    case Timex.parse(value_str, format_in) do
      {:ok, datetime} -> datetime
      {:error, _reason} -> Timex.parse!(value_str, format_in, :strftime)
    end
    |> NaiveDateTime.to_date()
  rescue
    _ ->
      raise ArgumentError, "#{value_str} could not be parsed as date with format #{format_in}"
  end

  defp parse(_value_str, :date, _opts), do: raise(ArgumentError, "Provide a :format_in option")

  defp parse(value_str, :time, %{format_in: format_in} = _opts) do
    case Timex.parse(value_str, format_in) do
      {:ok, datetime} -> datetime
      {:error, _reason} -> Timex.parse!(value_str, format_in, :strftime)
    end
    |> NaiveDateTime.to_time()
  rescue
    _ ->
      raise ArgumentError, "#{value_str} could not be parsed as time with format #{format_in}"
  end

  defp parse(_value_str, :time, _opts), do: raise(ArgumentError, "Provide a :format_in option")

  defp parse(value_str, :naive_datetime, %{format_in: format_in} = _opts) do
    case Timex.parse(value_str, format_in) do
      {:ok, datetime} -> datetime
      {:error, _reason} -> Timex.parse!(value_str, format_in, :strftime)
    end
  rescue
    _ ->
      raise ArgumentError, "#{value_str} could not be parsed as naive_datetime with format #{format_in}"
  end

  defp parse(value_str, :datetime, %{format_in: format_in} = opts) do
    case Timex.parse(value_str, format_in) do
      {:ok, datetime} -> datetime
      {:error, _reason} -> Timex.parse!(value_str, format_in, :strftime)
    end
    |> Timex.to_datetime(Map.get(opts, :timezone, :utc))
    |> case do
      {:error, reason} -> raise ArgumentError, inspect(reason)
      datetime -> datetime
    end
  rescue
    _ ->
      raise ArgumentError, "#{value_str} could not be parsed as datetime with format #{format_in}"
  end

  defp parse(value_str, :utc_datetime, opts), do: parse(value_str, :datetime, Map.put(opts, :timezone, :utc))

  defp parse(value_str, type, _opts),
    do: raise(ArgumentError, "Provide a :parser option as a function to customize type #{type} to value #{value_str}")

  @spec read(__MODULE__.t(), binary) :: any()
  def read(field, content) do
    content
    |> Field.depositionalize(field.field_value)
    |> String.trim()
    |> parse(field.type, Map.new(field.opts))
  end
end

defimpl Posexional.Protocol.FieldLength, for: Posexional.Field.Field do
  def length(%Posexional.Field.Field{field_value: value}), do: Posexional.Protocol.FieldLength.length(value)
end

defimpl Posexional.Protocol.FieldName, for: Posexional.Field.Field do
  def name(%Posexional.Field.Field{field_value: value}), do: Posexional.Protocol.FieldName.name(value)
end

defimpl Posexional.Protocol.FieldSize, for: Posexional.Field.Field do
  def size(%Posexional.Field.Field{field_value: value}), do: Posexional.Protocol.FieldSize.size(value)
end

defimpl Posexional.Protocol.FieldWrite, for: Posexional.Field.Field do
  def write(field, value), do: Posexional.Field.Value.write(field.field_value, value)
end

defimpl Posexional.Protocol.FieldRead, for: Posexional.Field.Field do
  def read(field, content), do: Posexional.Field.Field.read(field, content)
end
