defmodule Posexional.Field.ProgressiveNumber do
  @moduledoc """
  this module represent a single field in a row of a positional file with a progressive number
  """
  alias Posexional.Field

  defstruct \
    name: nil,
    size: nil,
    filler: ?\s,
    alignment: :right,
    counter: nil

  @spec new(atom, integer, char) :: %Posexional.Field.ProgressiveNumber{}
  def new(name, size, opts \\ []) do
    opts = Keyword.merge([name: name, size: size, filler: ?\s, alignment: :right], opts)

    %Field.ProgressiveNumber{name: opts[:name], size: opts[:size], filler: opts[:filler], alignment: opts[:alignment]}
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
  def write(field = %Posexional.Field.ProgressiveNumber{counter: counter}, _) do
    Posexional.Field.ProgressiveNumber.write(field, Agent.get_and_update(counter, &({&1, &1 + 1})))
  end
end

defimpl Posexional.Protocol.FieldRead, for: Posexional.Field.ProgressiveNumber do
  def read(_, content), do: content
end
