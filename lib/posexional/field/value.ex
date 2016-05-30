defmodule Posexional.Field.Value do
  @moduledoc """
  this module represent a single field in a row of a positional file
  """
  alias Posexional.Field

  defstruct \
    name: nil,
    size: nil,
    filler: ?\s,
    alignment: :left

  @spec new(atom, integer, Keyword.t) :: %Posexional.Field.Value{}
  def new(name, size, opts \\ []) do
    opts = Keyword.merge([name: name, size: size, filler: ?\s, alignment: :left], opts)
    %Posexional.Field.Value{name: opts[:name], size: opts[:size], filler: opts[:filler], alignment: opts[:alignment]}
  end

  @doc """
  outputs a field

  ## Examples

      iex> Posexional.Field.Value.write(Posexional.Field.Value.new(:test, 5), "test")
      "test "

      iex> Posexional.Field.Value.write(Posexional.Field.Value.new(:test, 5), "too long")
      ** (RuntimeError) The value too long is too long for the test field. The maximum size is 5 while the value is 8

      iex> Posexional.Field.Value.write(Posexional.Field.Value.new(:test, 10), "test")
      "test      "

      iex> Posexional.Field.Value.write(Posexional.Field.Value.new(:test, 10), "test")
      "test      "

      iex> Posexional.Field.Value.write(Posexional.Field.Value.new(:test, 10, filler: ?0), "test")
      "test000000"

      iex> Posexional.Field.Value.write(Posexional.Field.Value.new(:test, 10, filler: ?0, alignment: :right), "test")
      "000000test"
  """
  @spec write(%Field.Value{}, binary) :: binary
  def write(%Field.Value{filler: filler, size: size}, nil) do
    String.duplicate(to_string([filler]), size)
  end
  def write(field = %Field.Value{size: size}, value) when is_binary(value) and byte_size(value) <= size do
    value
    |> Field.positionalize(field)
  end
  def write(%Field.Value{name: name, size: size}, value) do
    raise "The value #{ value } is too long for the #{ name } field. "
       <> "The maximum size is #{size} while the value is #{byte_size(value)}"
  end
end

defimpl Posexional.Protocol.FieldLength, for: Posexional.Field.Value do
  def length(%Posexional.Field.Value{size: size}), do: size
end

defimpl Posexional.Protocol.FieldName, for: Posexional.Field.Value do
  def name(%Posexional.Field.Value{name: field_name}), do: field_name
end

defimpl Posexional.Protocol.FieldSize, for: Posexional.Field.Value do
  def size(%Posexional.Field.Value{size: size}), do: size
end

defimpl Posexional.Protocol.FieldWrite, for: Posexional.Field.Value do
  def write(field, value), do: Posexional.Field.Value.write(field, value)
end

defimpl Posexional.Protocol.FieldRead, for: Posexional.Field.Value do
  def read(field, content), do: Posexional.Field.depositionalize(content, field)
end
