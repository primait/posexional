defmodule Posexional.File do
  @moduledoc """
  a Posexional.File is the main struct to manage a positional file
  """
  alias Posexional.{Field, Row}

  defstruct rows: [],
            separator: "\n"

  def new(rows, separator \\ nil)

  def new(rows, nil) do
    %Posexional.File{rows: rows, separator: "\n"}
  end

  def new(rows, separator) do
    %Posexional.File{rows: rows, separator: separator}
  end

  @doc """
  creates a file from values

  ## Examples

      iex> Posexional.File.write(
      ...>   Posexional.File.new([ Posexional.Row.new(:row_test, [ Posexional.Field.Value.new(:test1, 5) ]) ]),
      ...>   [row_test: [test1: "test"], row_test: [test1: "t"]]
      ...> )
      "test \\nt    "

      iex> Posexional.File.write(
      ...>   Posexional.File.new([ Posexional.Row.new(:row_test, [ Posexional.Field.Value.new(:test1, 5) ]) ]),
      ...>   [row_test: [test1: "test"], ne: [test1: "t"]]
      ...> )
      ** (RuntimeError) row ne not found
  """
  @spec write(%Posexional.File{}, Keyword.t()) :: binary
  def write(file = %Posexional.File{separator: separator}, values) do
    file
    |> manage_counters
    |> get_lines(values)
    |> Enum.join(separator)
  end

  @spec write_path!(%Posexional.File{}, Keyword.t(), binary) :: binary
  def write_path!(file = %Posexional.File{separator: separator}, values, path) do
    File.open(path, [:write], fn handle ->
      file
      |> manage_counters
      |> get_lines(values)
      |> Stream.map(fn line ->
        IO.write(handle, line)
        IO.write(handle, separator)
      end)
      |> Stream.run()
    end)
  end

  @spec read(%Posexional.File{}, binary) :: Keyword.t()
  def read(%Posexional.File{separator: separator, rows: rows}, content) do
    content
    |> String.split(separator, trim: true)
    |> Enum.flat_map(fn content ->
      row = guess_row(content, rows)

      if is_nil(row) do
        [content]
      else
        Row.read(row, content)
      end
    end)
  end

  @spec get_lines(%Posexional.File{}, Keyword.t()) :: []
  defp get_lines(file, values) do
    values
    |> Stream.map(fn {row_name, values} -> {find_row(file, row_name), row_name, values} end)
    |> Stream.map(fn {row, row_name, values} ->
      if is_nil(row) do
        raise "row #{row_name} not found"
      end

      {:ok, out} = Row.write(row, values)
      out
    end)
  end

  @doc """
  adds a generator for every progressive_number_field in the file.

  The fields are grouped by name, so that you can specify many counters for every row
  """
  @spec manage_counters(%Posexional.File{}) :: %Posexional.File{}
  def manage_counters(file = %Posexional.File{rows: rows}) do
    counters = get_counters(file)
    %{file | rows: Stream.map(rows, &Row.manage_counters(&1, counters))}
  end

  @spec get_counters(%Posexional.File{}) :: [{atom, pid}]
  def get_counters(%Posexional.File{rows: rows}) do
    rows
    |> Stream.flat_map(& &1.fields)
    |> Stream.flat_map(fn
      %Field.ProgressiveNumber{name: name} -> [name]
      _ -> []
    end)
    |> Stream.uniq()
    |> Enum.map(fn name ->
      {:ok, pid} = Agent.start_link(fn -> 1 end)
      {name, pid}
    end)
  end

  @spec guess_row(binary, [%Row{}]) :: %Row{}
  defp guess_row(content, rows) do
    Enum.find(rows, nil, fn
      %Row{row_guesser: :always} -> true
      %Row{row_guesser: :never} -> false
      %Row{row_guesser: row_guesser} when is_function(row_guesser) -> row_guesser.(content)
    end)
  end

  @spec find_row(%Posexional.File{}, atom) :: %Row{}
  def find_row(%Posexional.File{rows: rows}, name) do
    Enum.find(rows, nil, fn %Row{name: row_name} -> row_name == name end)
  end
end
