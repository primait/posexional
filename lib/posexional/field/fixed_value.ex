defmodule Posexional.Field.FixedValue do
  @moduledoc """
  this module represent a fixed value field
  it is initialized with its value and it never change
  """

  @type t :: %__MODULE__{}

  defstruct value: ""

  @spec new(any()) :: t()
  def new(value) do
    %__MODULE__{value: value}
  end
end

defimpl Posexional.Protocol.FieldLength, for: Posexional.Field.FixedValue do
  def length(%Posexional.Field.FixedValue{value: value}), do: String.length(value)
end

defimpl Posexional.Protocol.FieldName, for: Posexional.Field.FixedValue do
  def name(_), do: :fixed_value
end

defimpl Posexional.Protocol.FieldWrite, for: Posexional.Field.FixedValue do
  def write(%Posexional.Field.FixedValue{value: value}, _), do: value
end

defimpl Posexional.Protocol.FieldSize, for: Posexional.Field.FixedValue do
  def size(%Posexional.Field.FixedValue{value: value}), do: String.length(value)
end

defimpl Posexional.Protocol.FieldRead, for: Posexional.Field.FixedValue do
  def read(_, content), do: content
end
