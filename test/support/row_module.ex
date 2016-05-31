defmodule Posexional.Test.RowModule do
  use Posexional.Row

  @name :test

  value :a, 8
  progressive_number 10, filler: ?0
  progressive_number 10, filler: ?0
  empty 10, filler: ?-
  fixed_value "test"
end
