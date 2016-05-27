defmodule Posexional.FieldEmpty do
  @moduledoc """
  this module represent a single field in a row of a positional file without a value
  """
  alias Posexional.FieldEmpty

  defstruct \
    size: nil,
    filler: ?\s


  @spec new(integer, char) :: %Posexional.FieldEmpty{}
  def new(size, filler \\ ?\s) do
    %Posexional.FieldEmpty{size: size, filler: filler}
  end

  @doc """
  outputs an empty field

  ## Examples

      iex> Posexional.FieldEmpty.write(%Posexional.FieldEmpty{filler: ?-, size: 10})
      "----------"

      iex> Posexional.FieldEmpty.write(%Posexional.FieldEmpty{filler: ?\\s, size: 2})
      "  "
  """
  @spec write(%FieldEmpty{}) :: binary
  def write(%FieldEmpty{filler: filler, size: size}) do
    String.duplicate(to_string([filler]), size)
  end
end

defimpl Posexional.Protocol.FieldLength, for: Posexional.FieldEmpty do
  def length(%Posexional.FieldEmpty{size: size}), do: size
  def name(_), do: 0
end

defimpl Posexional.Protocol.FieldName, for: Posexional.FieldEmpty do
  def name(_), do: :empty_field
end

defimpl Posexional.Protocol.FieldWrite, for: Posexional.FieldEmpty do
  def write(field, _) do
    Posexional.FieldEmpty.write(field)
  end
end

defimpl Posexional.Protocol.FieldRead, for: Posexional.FieldEmpty do
  def read(_, _), do: nil
end
