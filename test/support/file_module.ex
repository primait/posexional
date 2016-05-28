defmodule Posexional.Test.FileModule do
  use Posexional

  @separator "\n\r"

  row :test do
    value :a, 8
    progressive_number 10, filler: ?0
    progressive_number 10, filler: ?0
    empty 10, filler: ?-
    fixed_value "test"
  end

  row :test2 do
    value :f, 4, filler: ?d
    value :g, 4, filler: ?e
  end
end
