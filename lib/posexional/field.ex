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
    |> String.pad_trailing(size, filler_to_list_of_string(filler))
    |> String.slice(0, size)
  end
  def positionalize(value, %{alignment: :right, size: size, filler: filler}) do
    value
    |> String.pad_leading(size, filler_to_list_of_string(filler))
    |> String.slice(0, size)
  end

  @spec depositionalize(binary, map) :: binary
  def depositionalize(content, %Posexional.Field.ProgressiveNumber{filler: filler} = field) do
    content
    |> nil_if_empty(filler)
    |> remove_filler(field)
  end

  def depositionalize(content, %{filler: filler}) do
    content
    |> nil_if_empty(filler)
  end

  defp remove_filler(content, %{filler: filler, alignment: :right}) do
    String.replace_leading(content, filler_to_string(filler), "")
  end

  defp remove_filler(content, %{filler: filler, alignment: :left}) do
    String.replace_trailing(content, filler_to_string(filler), "")
  end

  defp filler_to_string(filler) do
    to_string([filler])
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
    |> String.to_charlist
    |> Enum.all?(&(&1 === filler))
  end
end
