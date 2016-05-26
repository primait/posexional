defmodule Posexional.FieldProgressiveNumber do
  @moduledoc """
  this module represent a single field in a row of a positional file with a progressive number
  """
  alias Posexional.{FieldProgressiveNumber,Field}

  defstruct \
    size: nil,
    filler: ?\s,
    alignment: :right,
    generator: nil

  @spec new(integer, char) :: %Posexional.FieldProgressiveNumber{}
  def new(size, filler \\ ?\s, alignment \\ :right) do
    %Posexional.FieldProgressiveNumber{size: size, filler: filler, alignment: alignment, generator: progressive_generator}
  end

  def progressive_generator do
    {:ok, generator} = Agent.start_link(fn -> 1 end)
    generator
  end

  @spec output(%FieldProgressiveNumber{}, integer) :: binary
  def output(field, value) do
    value
    |> to_string
    |> Field.positionalize(field)
  end
end

defimpl Posexional.Protocol.FieldLength, for: Posexional.FieldProgressiveNumber do
  def length(%Posexional.FieldProgressiveNumber{size: size}), do: size
end

defimpl Posexional.Protocol.FieldName, for: Posexional.FieldProgressiveNumber do
  def name(_), do: :progressive_number_field
end

defimpl Posexional.Protocol.FieldOutput, for: Posexional.FieldProgressiveNumber do
  def output(field = %Posexional.FieldProgressiveNumber{generator: generator}, _) do
    Posexional.FieldProgressiveNumber.output(field, Agent.get_and_update(generator, fn v -> {v, v+1} end))
  end
end
