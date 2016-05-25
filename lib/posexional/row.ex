defmodule Posexional.Row do
  @moduledoc """
  this module represent a row in a positional file
  """

  alias Posexional.{Row,Field}

  defstruct \
    name: nil,
    fields: [],
    separator: ""

  def new(name, fields, separator \\ "") do
    %Row{name: name, fields: fields, separator: separator}
  end

  @doc """
  calculate the row total length based on the passed fields

  ## Examples

    iex> Posexional.Row.new(:row_test, [])
    ...>   |> Posexional.Row.lenght
    0

    iex> Posexional.Row.new(:row_test, [Posexional.Field.new(:test1, 10), Posexional.Field.new(:test2, 20)])
    ...>   |> Posexional.Row.lenght
    30
  """
  @spec lenght(%Row{}) :: integer
  def lenght(%Row{fields: []}), do: 0
  def lenght(%Row{fields: fields}), do: do_lenght(0, fields)

  defp do_lenght(acc, []), do: acc
  defp do_lenght(acc, [%Field{size: size} | other_fields]) do
    do_lenght(acc + size, other_fields)
  end

  @doc """
  outputs a row

  ## Examples

    iex> Posexional.Row.new(:row_test, []) |> Posexional.Row.output([test: "test"])
    {:ok, ""}

    iex> Posexional.Row.new(:row_test, [Posexional.Field.new(:test1, 5), Posexional.Field.new(:test2, 10)])
    ...>   |> Posexional.Row.output([test1: "test1", test2: "test2"])
    {:ok, "test1test2     "}

    iex> Posexional.Row.new(:row_test, [Posexional.Field.new(:test1, 5), Posexional.Field.new(:test2, 10)])
    ...>   |> Posexional.Row.output([test1: "test1", non_existent: "test2"])
    {:ok, "test1          "}

    iex> Posexional.Row.new(:row_test, [Posexional.Field.new(:test1, 6)])
    ...>   |> Posexional.Row.output([test1: "test1", not_configured: "test2"])
    {:ok, "test1 "}

    iex> Posexional.Row.new(:row_test, [Posexional.Field.new(:test1, 5)])
    ...>   |> Posexional.Row.output([not_configured: "test2", another: "test3"])
    {:ok, "     "}
  """
  @spec output(%Row{}, Keyword.t) :: binary
  def output(%Row{fields: []}, _), do: {:ok, ""}
  def output(row = %Row{separator: separator}, values) do
    result = do_output(row, values)
    if Enum.all?(result, &valid?/1) do
      {:ok, result
        |> Enum.map(&(elem(&1, 1)))
        |> Enum.join(separator) }
    else
      {:error, error_message(result)}
    end
  end

  defp do_output(%Row{fields: fields}, values) do
    fields
    |> Stream.map(fn (field = %Field{name: field_name}) ->
      {field, Keyword.get(values, field_name, nil)}
    end)
    |> Enum.map(fn {field, value} -> {:ok, Field.output(field, value)} end)
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
  finds a field in the row by its name

  ## Examples

    iex> Posexional.Row.new(:row_test, []) |> Posexional.Row.find_field(:test)
    nil

    iex> Posexional.Row.new(:row_test, [Posexional.Field.new(:test, 5)]) |> Posexional.Row.find_field(:test)
    Posexional.Field.new(:test, 5)

    iex> Posexional.Row.new(:row_test, [Posexional.Field.new(:test, 5), Posexional.Field.new(:test2, 5)])
    ...>   |> Posexional.Row.find_field(:test2)
    Posexional.Field.new(:test2, 5)
  """
  @spec find_field(%Row{}, atom) :: %Field{}
  def find_field(%Row{fields: fields}, name) do
    Enum.find(fields, nil, fn %Field{name: field_name} -> field_name === name end)
  end
end
