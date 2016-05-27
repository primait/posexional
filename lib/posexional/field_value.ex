defmodule Posexional.FieldValue do
  @moduledoc """
  this module represent a single field in a row of a positional file
  """
  alias Posexional.{Field,FieldValue}

  defstruct \
    name: nil,
    size: nil,
    filler: ?\s,
    alignment: :left

  @spec new(atom, integer, char, atom) :: %Posexional.FieldValue{}
  def new(name, size, filler \\ ?\s, alignment \\ :left) do
    %Posexional.FieldValue{name: name, size: size, filler: filler, alignment: alignment}
  end

  @doc """
  outputs a field

  ## Examples

      iex> Posexional.FieldValue.write(Posexional.FieldValue.new(:test, 5), "test")
      "test "

      iex> Posexional.FieldValue.write(Posexional.FieldValue.new(:test, 5), "too long")
      ** (RuntimeError) The value too long is too long for the test field. The maximum size is 5 while the value is 8

      iex> Posexional.FieldValue.write(Posexional.FieldValue.new(:test, 10), "test")
      "test      "

      iex> Posexional.FieldValue.write(Posexional.FieldValue.new(:test, 10), "test")
      "test      "

      iex> Posexional.FieldValue.write(Posexional.FieldValue.new(:test, 10, ?0), "test")
      "test000000"

      iex> Posexional.FieldValue.write(Posexional.FieldValue.new(:test, 10, ?0, :right), "test")
      "000000test"
  """
  @spec write(%FieldValue{}, binary) :: binary
  def write(%FieldValue{filler: filler, size: size}, nil) do
    String.duplicate(to_string([filler]), size)
  end
  def write(field = %FieldValue{size: size}, value) when is_binary(value) and byte_size(value) <= size do
    value
    |> Field.positionalize(field)
  end
  def write(%FieldValue{name: name, size: size}, value) do
    raise "The value #{ value } is too long for the #{ name } field. "
       <> "The maximum size is #{size} while the value is #{byte_size(value)}"
  end
end

defimpl Posexional.Protocol.FieldLength, for: Posexional.FieldValue do
  def length(%Posexional.FieldValue{size: size}), do: size
end

defimpl Posexional.Protocol.FieldName, for: Posexional.FieldValue do
  def name(%Posexional.FieldValue{name: field_name}), do: field_name
end

defimpl Posexional.Protocol.FieldWrite, for: Posexional.FieldValue do
  def write(field, value), do: Posexional.FieldValue.write(field, value)
end

defimpl Posexional.Protocol.FieldRead, for: Posexional.FieldValue do
  def read(%Posexional.FieldValue{filler: filler, alignment: :left}, content) do
    String.rstrip(content, filler)
  end
  def read(%Posexional.FieldValue{filler: filler, alignment: :right}, content) do
    String.lstrip(content, filler)
  end
end
