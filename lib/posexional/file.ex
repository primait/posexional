defmodule Posexional.File do
  @moduledoc """
  a Posexional.File is the main struct to manage a positional file
  """
  alias Posexional.Row
  alias Posexional.Field
  import Enum

  @type t :: %__MODULE__{}

  defstruct rows: [],
            separator: "\n"

  def new(rows, separator \\ nil)

  def new(rows, nil) do
    %__MODULE__{rows: rows, separator: "\n"}
  end

  def new(rows, separator) do
    %__MODULE__{rows: rows, separator: separator}
  end

  @doc """
  creates a file from values

  ## Examples

      iex> #{__MODULE__}.write(
      ...>   Posexional.File.new([ Posexional.Row.new(:row_test, [ Posexional.Field.Value.new(:test1, 5) ]) ]),
      ...>   [row_test: [test1: "test"], row_test: [test1: "t"]]
      ...> )
      "test \\nt    "

      iex> #{__MODULE__}.write(
      ...>   #{__MODULE__}.new([ Posexional.Row.new(:row_test, [ Posexional.Field.Value.new(:test1, 5) ]) ]),
      ...>   [row_test: [test1: "test"], ne: [test1: "t"]]
      ...> )
      ** (RuntimeError) row ne not found
  """
  @spec write(t(), Keyword.t()) :: String.t()
  def write(file = %__MODULE__{separator: separator}, values) do
    file
    |> manage_counters()
    |> get_lines(values)
    |> join(separator)
  end

  @spec write_path!(t(), Keyword.t(), String.t()) :: String.t()
  def write_path!(file = %__MODULE__{separator: separator}, values, path) do
    File.open!(path, [:write], fn handle ->
      file
      |> manage_counters()
      |> get_lines(values)
      |> Stream.map(fn line ->
        IO.write(handle, line)
        IO.write(handle, separator)
      end)
      |> Stream.run()
    end)
  end

  @spec read(t(), String.t()) :: Keyword.t()
  def read(%__MODULE__{separator: separator, rows: rows}, content) do
    content
    |> String.split(separator)
    |> filter(fn
      "" -> false
      _ -> true
    end)
    |> flat_map(fn content ->
      row = guess_row(content, rows)

      if is_nil(row) do
        [content]
      else
        Row.read(row, content)
      end
    end)
  end

  @spec get_lines(t(), any()) :: any()
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
  @spec manage_counters(t()) :: t()
  def manage_counters(file = %__MODULE__{rows: rows}) do
    counters = get_counters(file)
    %{file | rows: Stream.map(rows, &Row.manage_counters(&1, counters))}
  end

  @spec get_counters(t()) :: [{atom, pid}]
  def get_counters(%__MODULE__{rows: rows}) do
    rows
    |> Stream.flat_map(& &1.fields)
    |> Stream.flat_map(fn
      %Field.ProgressiveNumber{name: name} -> [name]
      _ -> []
    end)
    |> Stream.uniq()
    |> map(fn name ->
      {:ok, pid} = Agent.start_link(fn -> 1 end)
      {name, pid}
    end)
  end

  @spec guess_row(String.t(), [Row.t()]) :: Row.t() | nil
  defp guess_row(content, rows) do
    find(rows, nil, fn
      %Row{row_guesser: :always} -> true
      %Row{row_guesser: :never} -> false
      %Row{row_guesser: row_guesser} when is_function(row_guesser) -> row_guesser.(content)
    end)
  end

  @spec find_row(t(), atom()) :: Row.t()
  def find_row(%__MODULE__{rows: rows}, name) do
    find(rows, nil, fn %Row{name: row_name} -> row_name === name end)
  end
end
