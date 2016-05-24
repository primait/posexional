defmodule Posexional.Field do
  alias Posexional.Field

  defstruct \
    name: nil,
    size: nil,
    filler: ' ',
    alignment: :left

  def new(name, size, filler \\ ?\s, alignment \\ :left) do
    %Posexional.Field{name: name, size: size, filler: filler, alignment: alignment}
  end

  @doc """
  outputs a field

  ## Examples

    iex> Posexional.Field.output(Posexional.Field.new(:test, 5), "test")
    "test "

    iex> Posexional.Field.output(Posexional.Field.new(:test, 5), "too long")
    ** (RuntimeError) The value too long is too long for the test field. The maximum size is 5 while the value is 8

    iex> Posexional.Field.output(Posexional.Field.new(:test, 10), "test")
    "test      "

    iex> Posexional.Field.output(Posexional.Field.new(:test, 10), "test")
    "test      "

    iex> Posexional.Field.output(Posexional.Field.new(:test, 10, ?0), "test")
    "test000000"

    iex> Posexional.Field.output(Posexional.Field.new(:test, 10, ?0, :right), "test")
    "000000test"
  """
  def output(field = %Field{size: size}, value) when is_binary(value) and byte_size(value) <= size do
    value
    |> justify(field)
  end
  def output(%Field{name: name, size: size}, value) do
    raise "The value #{ value } is too long for the #{ name } field. "
       <> "The maximum size is #{size} while the value is #{byte_size(value)}"
  end

  defp justify(value, %Field{alignment: :left, size: size, filler: filler}) do
    String.ljust(value, size, filler)
  end
  defp justify(value, %Field{alignment: :right, size: size, filler: filler}) do
    String.rjust(value, size, filler)
  end
end
