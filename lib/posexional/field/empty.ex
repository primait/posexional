defmodule Posexional.Field.Empty do
  @moduledoc """
  this module represent a single field in a row of a positional file without a value
  """
  alias Posexional.Field

  defstruct \
    size: nil,
    filler: ?\s

  @spec new(integer, char) :: %Posexional.Field.Empty{}
  def new(size, opts \\ []) do
    opts = Keyword.merge([size: size, filler: ?\s], opts)
    %Posexional.Field.Empty{size: opts[:size], filler: opts[:filler]}
  end

  @doc """
  outputs an empty field

  ## Examples

      iex> Posexional.Field.Empty.write(%Posexional.Field.Empty{filler: ?-, size: 10})
      "----------"

      iex> Posexional.Field.Empty.write(%Posexional.Field.Empty{filler: ?\\s, size: 2})
      "  "
  """
  @spec write(%Field.Empty{}) :: binary
  def write(%Field.Empty{filler: filler, size: size}) do
    String.duplicate(to_string([filler]), size)
  end
end

defimpl Posexional.Protocol.FieldLength, for: Posexional.Field.Empty do
  def length(%Posexional.Field.Empty{size: size}), do: size
  def name(_), do: 0
end

defimpl Posexional.Protocol.FieldName, for: Posexional.Field.Empty do
  def name(_), do: :empty_field
end

defimpl Posexional.Protocol.FieldSize, for: Posexional.Field.Empty do
  def size(%Posexional.Field.Empty{size: size}), do: size
end

defimpl Posexional.Protocol.FieldWrite, for: Posexional.Field.Empty do
  def write(field, _) do
    Posexional.Field.Empty.write(field)
  end
end

defimpl Posexional.Protocol.FieldRead, for: Posexional.Field.Empty do
  def read(_, _), do: nil
end
