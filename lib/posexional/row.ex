defmodule Posexional.Row do
  @moduledoc """
  this module represent a row in a positional file
  """

  alias Posexional.{Field, Row}
  alias Posexional.Protocol.{FieldLength, FieldName, FieldRead, FieldSize, FieldWrite}

  defstruct name: nil,
            fields: [],
            separator: "",
            row_guesser: :never,
            struct_module: nil

  @spec new(atom, [], Keyword.t()) :: %Row{}
  def new(name, fields, opts \\ []) do
    struct!(Row, Keyword.merge([name: name, fields: fields], opts))
  end

  @spec add_field(%Row{}, struct) :: %Row{}
  def add_field(row = %Row{fields: fields}, field) do
    %{row | fields: fields ++ [field]}
  end

  @spec add_fields(%Row{}, []) :: %Row{}
  def add_fields(row, fields) do
    Enum.reduce(fields, row, fn field, row -> add_field(row, field) end)
  end

  @spec manage_counters(%Row{}, [{atom, pid}]) :: %Row{}
  def manage_counters(row = %Posexional.Row{fields: fields}, counters) do
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

      iex> Posexional.Row.new(:row_test, []) |> Posexional.Row.write([test: "test"])
      {:ok, ""}

      iex> Posexional.Row.new(:row_test, [Posexional.Field.Value.new(:test1, 5), Posexional.Field.Value.new(:test2, 10)])
      ...>   |> Posexional.Row.write([test1: "test1", test2: "test2"])
      {:ok, "test1test2     "}

      iex> Posexional.Row.new(:row_test, [Posexional.Field.Value.new(:test1, 5), Posexional.Field.Value.new(:test2, 10)])
      ...>   |> Posexional.Row.write([test1: "test1", non_existent: "test2"])
      {:ok, "test1          "}

      iex> Posexional.Row.new(:row_test, [Posexional.Field.Value.new(:test1, 6)])
      ...>   |> Posexional.Row.write([test1: "test1", not_configured: "test2"])
      {:ok, "test1 "}

      iex> Posexional.Row.new(:row_test, [Posexional.Field.Value.new(:test1, 5)])
      ...>   |> Posexional.Row.write([not_configured: "test2", another: "test3"])
      {:ok, "     "}

      iex> Posexional.Row.new(:row_test, [Posexional.Field.Empty.new(5)])
      ...>   |> Posexional.Row.write([])
      {:ok, "     "}
  """
  @spec write(%Row{}, Keyword.t()) :: {atom, binary}
  def write(%Row{fields: []}, _), do: {:ok, ""}

  def write(row = %Row{separator: separator}, values) do
    result = do_output(row, values)

    if Enum.all?(result, &valid?/1) do
      {:ok,
       result
       |> Enum.map(&elem(&1, 1))
       |> Enum.join(separator)}
    else
      {:error, error_message(result)}
    end
  end

  defp do_output(%Row{fields: fields}, values) do
    fields
    |> Enum.map(fn field ->
      {field, Keyword.get(values, FieldName.name(field), nil)}
    end)
    |> Enum.map(fn {field, value} ->
      {:ok, FieldWrite.write(field, value)}
    end)
  end

  defp error?({:ok, _}), do: false
  defp error?({:error, _}), do: true

  defp valid?({:ok, _}), do: true
  defp valid?({:error, _}), do: false

  defp error_message(results) do
    results
    |> Enum.filter(&error?/1)
    |> do_error_message
  end

  defp do_error_message([error]) do
    "error on the field #{elem(error, 1)}"
  end

  defp do_error_message(errors) do
    field_names =
      errors
      |> Enum.map(&elem(&1, 1))
      |> Enum.join(", ")

    "errors on fields #{field_names}"
  end

  @doc """
  read a positional file row and convert it back to a keyword list of values
  """
  @spec read(%Row{}, binary) :: Keyword.t()
  def read(%Row{name: name, fields: fields, separator: separator, struct_module: struct_module}, content) do
    res =
      fields
      |> Enum.reduce({[], content}, fn field, {list, content} ->
        field_content = String.slice(content, 0, FieldSize.size(field))

        {list ++ [{FieldName.name(field), FieldRead.read(field, field_content)}],
         String.slice(content, (FieldSize.size(field) + String.length(separator))..-1)}
      end)
      |> elem(0)
      |> Enum.filter(fn {k, _} -> not (k in [:empty_field]) end)

    if is_nil(struct_module),
      do: [{name, res}],
      else: [{name, struct(struct_module, res)}]
  end

  @doc """
  finds a field in the row by its name

  ## Examples

      iex> Posexional.Row.new(:row_test, []) |> Posexional.Row.find_field(:test)
      nil

      iex> Posexional.Row.new(:row_test, [Posexional.Field.Value.new(:test, 5)]) |> Posexional.Row.find_field(:test)
      Posexional.Field.Value.new(:test, 5)

      iex> Posexional.Row.new(:row_test, [Posexional.Field.Value.new(:test, 5), Posexional.Field.Value.new(:test2, 5)])
      ...>   |> Posexional.Row.find_field(:test2)
      Posexional.Field.Value.new(:test2, 5)
  """
  @spec find_field(%Row{}, atom) :: %Field.Value{}
  def find_field(%Row{fields: fields}, name) do
    Enum.find(fields, nil, fn %Field.Value{name: field_name} -> field_name == name end)
  end

  @doc """
  calculate the row total length based on the passed fields

  ## Examples

      iex> Posexional.Row.new(:row_test, [])
      ...>   |> Posexional.Row.length
      0

      iex> Posexional.Row.new(:row_test, [Posexional.Field.Value.new(:test1, 10), Posexional.Field.Value.new(:test2, 20)])
      ...>   |> Posexional.Row.length
      30
  """
  @spec length(%Row{}) :: integer
  def length(%Row{fields: []}), do: 0
  def length(%Row{fields: fields}), do: do_length(0, fields)

  defp do_length(acc, []), do: acc

  defp do_length(acc, [field | other_fields]) do
    do_length(acc + FieldLength.length(field), other_fields)
  end

  @doc """
  Given a row and a field name calculate the field offset

  ## Examples

      iex> Posexional.Row.new(:test, [Posexional.Field.Value.new(:test1, 10), Posexional.Field.Value.new(:test2, 20)])
      ...>     |> Posexional.Row.offset(:test1)
      1

      iex> Posexional.Row.new(:test, [Posexional.Field.Value.new(:test1, 10), Posexional.Field.Value.new(:test2, 20)])
      ...>    |> Posexional.Row.offset(:test2)
      11

      iex> Posexional.Row.new(:test, [Posexional.Field.Value.new(:test1, 10), Posexional.Field.Value.new(:test2, 20)])
      ...>     |> Posexional.Row.offset(:test_not_existent)
      ** (ArgumentError) the field test_not_existent doesn't exists

      iex> Posexional.Row.new(:test, [])
      ...>     |> Posexional.Row.offset(:test)
      nil
  """
  @spec offset(%Row{}, atom) :: integer
  def offset(%Row{fields: []}, _), do: nil
  def offset(%Row{fields: fields}, field_name), do: do_offset(1, fields, field_name)

  defp do_offset(_, [], field_name), do: raise(ArgumentError, "the field #{field_name} doesn't exists")
  defp do_offset(acc, :ok, _), do: acc

  defp do_offset(acc, [field | other_fields], field_name) do
    if field_name == FieldName.name(field) do
      do_offset(acc, :ok, field_name)
    else
      do_offset(acc + FieldLength.length(field), other_fields, field_name)
    end
  end

  @doc """
  merge fields from another row
  """
  @spec fields_from(%Row{}, %Row{}) :: %Row{}
  def fields_from(to, %Row{fields: other_fields}) do
    %{to | fields: to.fields ++ other_fields}
  end
end
