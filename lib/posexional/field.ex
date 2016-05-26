defmodule Posexional.Field do
  @moduledoc """
  generic utility functions for fields
  """

  @doc """
  justify a value given alignment, size and filler char, if the given value is longer it gets trimmed

  ## Examples

    iex> Posexional.Field.positionalize("test", %{alignment: :left, size: 10, filler: ?\\s})
    "test      "

    iex> Posexional.Field.positionalize("test", %{alignment: :right, size: 10, filler: ?\\s})
    "      test"

    iex> Posexional.Field.positionalize("test", %{alignment: :right, size: 5, filler: ?\\s})
    " test"

    iex> Posexional.Field.positionalize("test", %{alignment: :right, size: 5, filler: ?-})
    "-test"

    iex> Posexional.Field.positionalize("testtest", %{alignment: :right, size: 5, filler: ?-})
    "testt"
  """
  @spec positionalize(binary, map) :: binary
  def positionalize(value, %{alignment: :left, size: size, filler: filler}) do
    value
    |> String.ljust(size, filler)
    |> String.slice(0, size)
  end
  def positionalize(value, %{alignment: :right, size: size, filler: filler}) do
    value
    |> String.rjust(size, filler)
    |> String.slice(0, size)
  end
end
