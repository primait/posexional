defmodule Posexional.File do
  @moduledoc """
  a Posexional.File is the main struct to manage a positional file
  """
  alias Posexional.{Field, Row}

  @type t :: %__MODULE__{}

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

      iex> write(
      ...>   Posexional.File.new([ Posexional.Row.new(:row_test, [ Posexional.Field.Value.new(:test1, 5) ]) ]),
      ...>   [row_test: [test1: "test"], row_test: [test1: "t"]]
      ...> )
      "test \\nt    "

      iex> write(
      ...>   Posexional.File.new([ Posexional.Row.new(:row_test, [ Posexional.Field.Value.new(:test1, 5) ]) ]),
      ...>   [row_test: [test1: "test"], ne: [test1: "t"]]
      ...> )
      ** (RuntimeError) row ne not found
  """
  @spec write(Posexional.File.t(), Keyword.t()) :: binary
  def write(file = %Posexional.File{separator: separator}, values) do
    file
    |> manage_counters
    |> get_lines(values)
    |> Enum.join(separator)
  end

  @spec write_path!(Posexional.File.t(), Keyword.t(), binary) :: {:ok, binary} | {:error, any}
  def write_path!(file = %Posexional.File{separator: separator}, values, path) do
    with {:ok, _} <-
           File.open(path, [:write], fn handle ->
             file
             |> manage_counters
             |> get_lines(values)
             |> Stream.intersperse(separator)
             |> Stream.each(&IO.binwrite(handle, &1))
             |> Stream.run()
           end) do
      {:ok, path}
    end
  end

  @spec read(Posexional.File.t(), binary) :: [tuple() | String.t()]
  def read(%Posexional.File{separator: separator, rows: rows}, content) do
    content
    |> String.split(separator)
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> Enum.flat_map(fn content ->
      row = guess_row(content, rows)

      if is_nil(row) do
        [content]
      else
        Row.read(row, content)
      end
    end)
  end

  @spec stream(Enumerable.t(), Posexional.File.t()) :: Enumerable.t()
  def stream(str, _file = %{separator: separator, rows: rows}) do
    str
    |> Stream.concat([separator])
    |> Stream.transform("", &stream_split(&1, &2, separator))
    |> Stream.reject(&(&1 === ""))
    |> Stream.flat_map(&to_rows(&1, rows))
  end

  defp stream_split(bin, acc, separator) do
    {remaining, splitted} =
      acc
      |> Kernel.<>(bin)
      |> String.split(separator)
      |> List.pop_at(-1)

    {splitted, remaining}
  end

  defp to_rows(content, rows),
    do: binary_to_rows(content, guess_row(content, rows))

  defp binary_to_rows(content, nil),
    do: [content]

  defp binary_to_rows(content, row),
    do: Row.read(row, content)

  @spec get_lines(Posexional.File.t(), Keyword.t()) :: Enumerable.t()
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
  @spec manage_counters(Posexional.File.t()) :: Posexional.File.t()
  def manage_counters(file = %Posexional.File{rows: rows}) do
    counters = get_counters(file)
    %{file | rows: Stream.map(rows, &Row.manage_counters(&1, counters))}
  end

  @spec get_counters(Posexional.File.t()) :: [{atom, pid}]
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

  @spec guess_row(binary, [Row.t()]) :: Row.t() | nil
  defp guess_row(content, rows) do
    Enum.find(rows, nil, fn
      %Row{row_guesser: :always} -> true
      %Row{row_guesser: :never} -> false
      %Row{row_guesser: row_guesser} when is_function(row_guesser) -> row_guesser.(content)
    end)
  end

  @spec find_row(Posexional.File.t(), atom) :: Row.t()
  def find_row(%Posexional.File{rows: rows}, name) do
    Enum.find(rows, nil, fn %Row{name: row_name} -> row_name == name end)
  end
end
