defmodule Posexional.Test.FileModule do
  use PosexionalFile

  @separator "\n\r"

  row :test_inline do
    value :a, 8
    progressive_number(10, filler: ?0)
    progressive_number(10, filler: ?0)
    empty(10, filler: ?-)
    fixed_value("test")
  end

  row :test_with_guesser, :always do
    value :f, 4, filler: ?d
    value :g, 4, filler: ?e
  end

  row(Posexional.Test.RowModule)
end
