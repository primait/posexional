defmodule Posexional.Field do
  @moduledoc """
  generic utility functions for fields
  """

  @doc """
  justify a value given alignment, size and filler char, if the given value
  is longer it gets trimmed

  ## Examples

      iex> #{__MODULE__}.positionalize("test",
      ...>   %{alignment: :left, size: 10, filler: ?\\s})
      "test      "

      iex> #{__MODULE__}.positionalize("test",
      ...>   %{alignment: :right, size: 10, filler: ?\\s})
      "      test"

      iex> #{__MODULE__}.positionalize("test",
      ...>   %{alignment: :right, size: 5, filler: ?\\s})
      " test"

      iex> #{__MODULE__}.positionalize("test",
      ...>   %{alignment: :right, size: 5, filler: ?-})
      "-test"

      iex> #{__MODULE__}.positionalize("testtest",
      ...>   %{alignment: :right, size: 5, filler: ?-})
      "testt"
  """
  @spec positionalize(String.t(), map()) :: String.t()
  def positionalize(value, %{alignment: :left, size: size, filler: filler}) do
    value
    |> String.pad_trailing(size, filler_to_list_of_string(filler))
    |> String.slice(0, size)
  end

  def positionalize(value, %{alignment: :right, size: size, filler: filler}) do
    value
    |> String.pad_leading(size, filler_to_list_of_string(filler))
    |> String.slice(0, size)
  end

  def depositionalize(content, %{filler: filler}) do
    nil_if_empty(content, filler)
  end

  defp filler_to_list_of_string(filler) do
    [to_string([filler])]
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
    |> String.to_charlist()
    |> Enum.all?(&(&1 === filler))
  end
end
