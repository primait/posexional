defmodule Posexional.Row do
  @moduledoc """
  this module represent a row in a positional file
  """

  alias Posexional.Field
  alias Posexional.Protocol.{FieldName, FieldLength, FieldSize, FieldWrite, FieldRead}
  import Enum

  @type t :: %__MODULE__{}

  defstruct name: nil,
            fields: [],
            separator: "",
            row_guesser: :never

  @spec new(atom(), [], Keyword.t()) :: t()
  def new(name, fields, opts \\ []) do
    struct!(__MODULE__, Keyword.merge([name: name, fields: fields], opts))
  end

  @spec add_field(t(), struct) :: t()
  def add_field(row = %__MODULE__{fields: fields}, field) do
    %{row | fields: fields ++ [field]}
  end

  @spec add_fields(t(), []) :: t()
  def add_fields(row, fields) do
    fields
    |> reduce(row, fn field, row -> add_field(row, field) end)
  end

  @spec manage_counters(t(), [{atom, pid}]) :: t()
  def manage_counters(row = %__MODULE__{fields: fields}, counters) do
    new_fields =
      Stream.map(fields, fn
        f = %Field.ProgressiveNumber{name: name} -> %{f | counter: Keyword.get(counters, name)}
        f -> f
      end)

    %{row | fields: new_fields}
  end

  @doc """
  outputs a row

  ## Examples

      iex> #{__MODULE__}.new(:row_test, []) |> #{__MODULE__}.write([test: "test"])
      {:ok, ""}

      iex> #{__MODULE__}.new(:row_test, [Posexional.Field.Value.new(:test1, 5), Posexional.Field.Value.new(:test2, 10)])
      ...>   |> #{__MODULE__}.write([test1: "test1", test2: "test2"])
      {:ok, "test1test2     "}

      iex> #{__MODULE__}.new(:row_test, [Posexional.Field.Value.new(:test1, 5), Posexional.Field.Value.new(:test2, 10)])
      ...>   |> #{__MODULE__}.write([test1: "test1", non_existent: "test2"])
      {:ok, "test1          "}

      iex> #{__MODULE__}.new(:row_test, [Posexional.Field.Value.new(:test1, 6)])
      ...>   |> #{__MODULE__}.write([test1: "test1", not_configured: "test2"])
      {:ok, "test1 "}

      iex> #{__MODULE__}.new(:row_test, [Posexional.Field.Value.new(:test1, 5)])
      ...>   |> #{__MODULE__}.write([not_configured: "test2", another: "test3"])
      {:ok, "     "}

      iex> #{__MODULE__}.new(:row_test, [Posexional.Field.Empty.new(5)])
      ...>   |> #{__MODULE__}.write([])
      {:ok, "     "}
  """
  @spec write(t(), Keyword.t()) :: {atom(), String.t()}
  def write(%__MODULE__{fields: []}, _), do: {:ok, ""}

  def write(row = %__MODULE__{separator: separator}, values) do
    result = do_output(row, values)

    if all?(result, &valid?/1) do
      {:ok,
       result
       |> map(&elem(&1, 1))
       |> join(separator)}
    else
      {:error, error_message(result)}
    end
  end

  defp do_output(%__MODULE__{fields: fields}, values) do
    fields
    |> map(fn field ->
      {field, Keyword.get(values, FieldName.name(field), nil)}
    end)
    |> map(fn {field, value} ->
      {:ok, FieldWrite.write(field, value)}
    end)
  end

  defp error?({:ok, _}), do: false
  defp error?({:error, _}), do: true

  defp valid?({:ok, _}), do: true
  defp valid?({:error, _}), do: false

  defp error_message(results) do
    results
    |> filter(&error?/1)
    |> do_error_message()
  end

  defp do_error_message([error]) do
    "error on the field #{elem(error, 1)}"
  end

  defp do_error_message(errors) do
    field_names =
      errors
      |> map(&elem(&1, 1))
      |> join(", ")

    "errors on fields #{field_names}"
  end

  @doc """
  read a positional file row and convert it back to a keyword list of values
  """
  @spec read(t(), String.t()) :: Keyword.t()
  def read(%__MODULE__{name: name, fields: fields, separator: separator}, content) do
    res =
      fields
      |> reduce({[], content}, fn field, {list, content} ->
        field_content = String.slice(content, 0, FieldSize.size(field))

        {list ++ [{FieldName.name(field), FieldRead.read(field, field_content)}],
         String.slice(content, (FieldSize.size(field) + String.length(separator))..-1)}
      end)
      |> elem(0)
      |> filter(fn {k, _} -> not (k in [:empty_field]) end)

    [{name, res}]
  end

  @doc """
  finds a field in the row by its name

  ## Examples

      iex> #{__MODULE__}.new(:row_test, []) |> #{__MODULE__}.find_field(:test)
      nil

      iex> #{__MODULE__}.new(:row_test, [Posexional.Field.Value.new(:test, 5)]) |> #{__MODULE__}.find_field(:test)
      Posexional.Field.Value.new(:test, 5)

      iex> #{__MODULE__}.new(:row_test, [Posexional.Field.Value.new(:test, 5), Posexional.Field.Value.new(:test2, 5)])
      ...>   |> #{__MODULE__}.find_field(:test2)
      Posexional.Field.Value.new(:test2, 5)
  """
  @spec find_field(t(), atom()) :: Field.Value.t()
  def find_field(%__MODULE__{fields: fields}, name) do
    find(fields, nil, fn %Field.Value{name: field_name} -> field_name === name end)
  end

  @doc """
  calculate the row total length based on the passed fields

  ## Examples

      iex> #{__MODULE__}.new(:row_test, [])
      ...>   |> #{__MODULE__}.length
      0

      iex> #{__MODULE__}.new(:row_test, [Posexional.Field.Value.new(:test1, 10), Posexional.Field.Value.new(:test2, 20)])
      ...>   |> #{__MODULE__}.length
      30
  """
  @spec length(t()) :: integer()
  def length(%__MODULE__{fields: []}), do: 0
  def length(%__MODULE__{fields: fields}), do: do_lenght(0, fields)

  defp do_lenght(acc, []), do: acc

  defp do_lenght(acc, [field | other_fields]) do
    do_lenght(acc + FieldLength.length(field), other_fields)
  end

  @doc """
  Given a row and a field name calculate the field offset

  ## Examples

      iex> #{__MODULE__}.new(:test, [Posexional.Field.Value.new(:test1, 10), Posexional.Field.Value.new(:test2, 20)])
      ...>     |> #{__MODULE__}.offset(:test1)
      1

      iex> #{__MODULE__}.new(:test, [Posexional.Field.Value.new(:test1, 10), Posexional.Field.Value.new(:test2, 20)])
      ...>    |> #{__MODULE__}.offset(:test2)
      11

      iex> #{__MODULE__}.new(:test, [Posexional.Field.Value.new(:test1, 10), Posexional.Field.Value.new(:test2, 20)])
      ...>     |> #{__MODULE__}.offset(:test_not_existent)
      ** (ArgumentError) the field test_not_existent doesn't exists

      iex> #{__MODULE__}.new(:test, [])
      ...>     |> #{__MODULE__}.offset(:test)
      nil
  """
  @spec offset(t(), atom()) :: integer()
  def offset(%__MODULE__{fields: []}, _), do: nil
  def offset(%__MODULE__{fields: fields}, field_name), do: do_offset(1, fields, field_name)

  defp do_offset(_, [], field_name),
    do: raise(ArgumentError, "the field #{field_name} doesn't exists")

  defp do_offset(acc, :ok, _), do: acc

  defp do_offset(acc, [field | other_fields], field_name) do
    if field_name === FieldName.name(field) do
      do_offset(acc, :ok, field_name)
    else
      do_offset(acc + FieldLength.length(field), other_fields, field_name)
    end
  end

  @doc """
  merge fields from another row
  """
  @spec fields_from(t(), t()) :: t()
  def fields_from(to, %__MODULE__{fields: other_fields}) do
    %{to | fields: to.fields ++ other_fields}
  end
end
