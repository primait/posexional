defmodule Posexional.Test.RowModule do
  use PosexionalRow

  name __MODULE__
  guesser &__MODULE__.matcher/1
  separator ""

  value :a, 8
  progressive_number 10, filler: ?0
  progressive_number 10, filler: ?0
  empty 10, filler: ?-
  fixed_value "test"


  def matcher(<< _ :: binary-size(38), "test" >>), do: true
  def matcher(_), do: false
end
