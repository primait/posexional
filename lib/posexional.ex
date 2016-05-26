defmodule Posexional do
  @moduledoc """
  main module
  """
  alias Posexional.File

  @spec write(%Posexional.File{}, Keyword.t) :: binary
  def write(positional_file, values) do
    File.output(positional_file, values)
  end

  @spec read(%Posexional.File{}, binary) :: Keyword.t
  def read(positional_file, content) do
  end
end
