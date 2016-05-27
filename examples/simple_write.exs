defmodule Posexional.Examples.SimpleWrite do
  alias Posexional.Field

  def run! do
    beatles_row = Posexional.Row.new(:beatles, [
      Field.Value.new(:code, 5, ?0, :right),
      Field.ProgressiveNumber.new(5, ?0),
      Field.FixedValue.new("AA"),
      Field.FixedValue.new("01"),
      Field.Value.new(:name, 10, ?-),
      Field.Empty.new(2),
      Field.Value.new(:end, 1, ?!)
    ])

    file = Posexional.File.new([beatles_row])

    Posexional.write(file, [beatles: [
      code: "B1", name: "george"
    ], beatles: [
      code: "B2", name: "john"
    ], beatles: [
      code: "B2", name: "ringo"
    ], beatles: [
      code: "B2", name: "paul"
    ]])
  end
end

Posexional.Examples.SimpleWrite.run!
