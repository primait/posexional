defmodule Posexional.Row do
  @moduledoc """
  this module represent a row in a positional file
  """

  alias Posexional.{Row,FieldValue}
  alias Posexional.Protocol.{FieldName,FieldLength,FieldWrite,FieldRead}

  defstruct \
    name: nil,
    fields: [],
    separator: "",
    row_guesser: nil

  def new(name, fields, separator \\ "", row_guesser \\ fn _ -> false end) do
    %Row{name: name, fields: fields, separator: separator, row_guesser: row_guesser}
  end

  @doc """
  outputs a row

  ## Examples

    iex> Posexional.Row.new(:row_test, []) |> Posexional.Row.write([test: "test"])
    {:ok, ""}

    iex> Posexional.Row.new(:row_test, [Posexional.FieldValue.new(:test1, 5), Posexional.FieldValue.new(:test2, 10)])
    ...>   |> Posexional.Row.write([test1: "test1", test2: "test2"])
    {:ok, "test1test2     "}

    iex> Posexional.Row.new(:row_test, [Posexional.FieldValue.new(:test1, 5), Posexional.FieldValue.new(:test2, 10)])
    ...>   |> Posexional.Row.write([test1: "test1", non_existent: "test2"])
    {:ok, "test1          "}

    iex> Posexional.Row.new(:row_test, [Posexional.FieldValue.new(:test1, 6)])
    ...>   |> Posexional.Row.write([test1: "test1", not_configured: "test2"])
    {:ok, "test1 "}

    iex> Posexional.Row.new(:row_test, [Posexional.FieldValue.new(:test1, 5)])
    ...>   |> Posexional.Row.write([not_configured: "test2", another: "test3"])
    {:ok, "     "}

    iex> Posexional.Row.new(:row_test, [Posexional.FieldEmpty.new(5)])
    ...>   |> Posexional.Row.write([])
    {:ok, "     "}
  """
  @spec write(%Row{}, Keyword.t) :: {atom, binary}
  def write(%Row{fields: []}, _), do: {:ok, ""}
  def write(row = %Row{separator: separator}, values) do
    result = do_output(row, values)
    if Enum.all?(result, &valid?/1) do
      {:ok, result
        |> Enum.map(&(elem(&1, 1)))
        |> Enum.join(separator)}
    else
      {:error, error_message(result)}
    end
  end

  defp do_output(%Row{fields: fields}, values) do
    fields
    |> Enum.map(fn (field) ->
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
    field_names = errors
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.join(", ")
    "errors on fields #{field_names}"
  end

  @doc """
  read a positional file row and convert it back to a keyword list of values
  """
  @spec read(%Posexional.Row{}, binary) :: Keyword.t
  def read(%Row{name: name, fields: fields}, content) do
    res = fields
    |> Enum.reduce({[], content}, fn field, {list, content} ->
      field_content = String.slice(content, 0, field.size)
      {
        list ++ [{FieldName.name(field), FieldRead.read(field, field_content)}],
        String.slice(content, field.size..-1)
      }
    end)
    |> elem(0)
    |> Enum.filter(fn {k, v} -> not k in [:progressive_number_field, :empty_field] end)
    [{name, res}]
  end

  @doc """
  finds a field in the row by its name

  ## Examples

    iex> Posexional.Row.new(:row_test, []) |> Posexional.Row.find_field(:test)
    nil

    iex> Posexional.Row.new(:row_test, [Posexional.FieldValue.new(:test, 5)]) |> Posexional.Row.find_field(:test)
    Posexional.FieldValue.new(:test, 5)

    iex> Posexional.Row.new(:row_test, [Posexional.FieldValue.new(:test, 5), Posexional.FieldValue.new(:test2, 5)])
    ...>   |> Posexional.Row.find_field(:test2)
    Posexional.FieldValue.new(:test2, 5)
  """
  @spec find_field(%Row{}, atom) :: %FieldValue{}
  def find_field(%Row{fields: fields}, name) do
    Enum.find(fields, nil, fn %FieldValue{name: field_name} -> field_name === name end)
  end

  @doc """
  calculate the row total length based on the passed fields

  ## Examples

    iex> Posexional.Row.new(:row_test, [])
    ...>   |> Posexional.Row.length
    0

    iex> Posexional.Row.new(:row_test, [Posexional.FieldValue.new(:test1, 10), Posexional.FieldValue.new(:test2, 20)])
    ...>   |> Posexional.Row.length
    30
  """
  @spec length(%Row{}) :: integer
  def length(%Row{fields: []}), do: 0
  def length(%Row{fields: fields}), do: do_lenght(0, fields)

  defp do_lenght(acc, []), do: acc
  defp do_lenght(acc, [field | other_fields]) do
    do_lenght(acc + FieldLength.length(field), other_fields)
  end
end
