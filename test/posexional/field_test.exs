defmodule Posexional.FieldTest do
  use Posexional.Case, async: true
  doctest Posexional.Field
  use ExCheck

  property :positionalize do
    for_all {value, size, filler} in {binary(10), non_neg_integer, char} do
      implies size >= String.length(value) do
        value <> String.duplicate(to_string([filler]), size - String.length(value) )
          === Posexional.Field.positionalize(value, %{alignment: :left, size: size, filler: filler})
      end
    end
  end
end
