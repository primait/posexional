defmodule Posexional.File do
  @moduledoc """
  a Posexional.File is the main struct to manage a positional file
  """

  alias Posexional.{File,Row}

  defstruct \
    rows: [],
    separator: "\n"


  def new(rows, separator \\ "\n") do
    %File{rows: rows, separator: separator}
  end

  @doc """
  creates a file from values

  ## Examples

    iex> Posexional.File.write(
    ...>   Posexional.File.new([ Posexional.Row.new(:row_test, [ Posexional.FieldValue.new(:test1, 5) ]) ]),
    ...>   [row_test: [test1: "test"], row_test: [test1: "t"]]
    ...> )
    "test \\nt    "

    iex> Posexional.File.write(
    ...>   Posexional.File.new([ Posexional.Row.new(:row_test, [ Posexional.FieldValue.new(:test1, 5) ]) ]),
    ...>   [row_test: [test1: "test"], ne: [test1: "t"]]
    ...> )
    ** (RuntimeError) row ne not found
  """
  @spec write(%File{}, Keyword.t) :: binary
  def write(file = %File{separator: separator}, values) do
    values
    |> Stream.map(fn {row_name, values} -> {find_row(file, row_name), row_name, values} end)
    |> Enum.map(fn {row, row_name, values} ->
      if is_nil(row) do
        raise "row #{row_name} not found"
      end
      {:ok, out} = Row.write(row, values)
      out
    end)
    |> Enum.join(separator)
  end

  def read(%File{separator: separator, rows: rows}, content) do
    content
    |> String.split(separator)
    |> Enum.flat_map(fn content ->
      row = guess_row(content, rows)
      if is_nil(row) do
        content
      else
        Row.read(row, content)
      end
    end)
  end

  defp guess_row(content, rows) do
    Enum.find(rows, nil, fn %Row{row_guesser: row_guesser} -> row_guesser.(content) end)
  end

  @spec find_row(%File{}, atom) :: %Row{}
  def find_row(%File{rows: rows}, name) do
    Enum.find(rows, nil, fn %Row{name: row_name} -> row_name === name end)
  end
end
