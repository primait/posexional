defmodule Posexional.Field.ProgressiveNumber do
  @moduledoc """
  this module represent a single field in a row of a positional file with a progressive number
  """
  alias Posexional.Field

  defstruct \
    size: nil,
    filler: ?\s,
    alignment: :right,
    generator: nil

  @spec new(integer, char) :: %Posexional.Field.ProgressiveNumber{}
  def new(size, filler \\ ?\s, alignment \\ :right) do
    %Field.ProgressiveNumber{size: size, filler: filler, alignment: alignment, generator: progressive_generator}
  end

  def progressive_generator do
    {:ok, generator} = Agent.start_link(fn -> 1 end)
    generator
  end

  @spec write(%Field.ProgressiveNumber{}, integer) :: binary
  def write(field, value) do
    value
    |> to_string
    |> Field.positionalize(field)
  end
end

defimpl Posexional.Protocol.FieldLength, for: Posexional.Field.ProgressiveNumber do
  def length(%Posexional.Field.ProgressiveNumber{size: size}), do: size
end

defimpl Posexional.Protocol.FieldName, for: Posexional.Field.ProgressiveNumber do
  def name(_), do: :progressive_number_field
end

defimpl Posexional.Protocol.FieldWrite, for: Posexional.Field.ProgressiveNumber do
  def write(field = %Posexional.Field.ProgressiveNumber{generator: generator}, _) do
    Posexional.Field.ProgressiveNumber.write(field, Agent.get_and_update(generator, fn v -> {v, v + 1} end))
  end
end

defimpl Posexional.Protocol.FieldRead, for: Posexional.Field.ProgressiveNumber do
  def read(_, content), do: content
end
