defmodule Posexional.Field do
  @moduledoc """
  generic utility functions for fields
  """

  @doc """
  justify a value given alignment, size and filler char, if the given value
  is longer it gets trimmed

  ## Examples

      iex> Posexional.Field.positionalize("test",
      ...>   %{alignment: :left, size: 10, filler: ?\\s})
      "test      "

      iex> Posexional.Field.positionalize("test",
      ...>   %{alignment: :right, size: 10, filler: ?\\s})
      "      test"

      iex> Posexional.Field.positionalize("test",
      ...>   %{alignment: :right, size: 5, filler: ?\\s})
      " test"

      iex> Posexional.Field.positionalize("test",
      ...>   %{alignment: :right, size: 5, filler: ?-})
      "-test"

      iex> Posexional.Field.positionalize("testtest",
      ...>   %{alignment: :right, size: 5, filler: ?-})
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

  def depositionalize(content, %{alignment: :left, filler: filler}) do
    content
    |> nil_if_empty(filler)
  end
  def depositionalize(content, %{alignment: :right, filler: filler}) do
    content
    |> nil_if_empty(filler)
  end

  @doc """
  nil if the value is an empty string, or a string containing only the filler
  """
  def nil_if_empty("", _), do: nil
  def nil_if_empty(v, filler) do
    if contains_only?(v, filler) do
      nil
    else
      v
    end
  end

  @doc """
  true if the value passed contains only the filler value
  """
  def contains_only?(v, filler) do
    v
    |> String.to_charlist
    |> Enum.all?(&(&1 === filler))
  end
end
