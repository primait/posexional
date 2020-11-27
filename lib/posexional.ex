defmodule Posexional do
  @external_resource readme = "README.md"
  @moduledoc """
  Posexional is a library to manage positional files in Elixir.

  #{
    readme
    |> File.read!()
    |> String.split("<!--MDOC !-->")
    |> Enum.fetch!(1)
  }
  """

  @doc """
  write a positional file with the given struct and data
  """
  @spec write(%Posexional.File{}, Keyword.t()) :: binary
  def write(positional_file, values) do
    Posexional.File.write(positional_file, values)
  end

  @doc """
  same as write/2, but with a path to a new file to write the result to
  """
  @spec write_file!(%Posexional.File{}, Keyword.t(), binary) :: {:ok, any} | {:error, any}
  def write_file!(positional_file, values, path) do
    Posexional.File.write_path!(positional_file, values, path)
  end

  @doc """
  read a positional stream of data with the given struct, returns a keyword list of the extracted data
  """
  @spec read(%Posexional.File{}, binary) :: Keyword.t()
  def read(positional_file, content) do
    Posexional.File.read(positional_file, content)
  end

  @doc """
  same as read/2, but with a path to a file to read the stream from
  """
  @spec read_file!(%Posexional.File{}, binary) :: Keyword.t()
  def read_file!(file, path) do
    content = File.read!(path)
    read(file, content)
  end

  @spec stream!(%Posexional.File{}, binary) :: any()
  def stream!(file, path) do
    path
    |> File.stream!([], 2048)
    |> Posexional.File.stream(file)
  end
end
