defmodule BeatlesFile do
  use Posexional

  @separator "\n"

  row :beatles, &BeatlesFile.george_matcher/1 do # add :always here to always match this row while reading
    value :code, 5, filler: ?0, alignment: :right
    progressive_number :code, 5
    fixed_value "AA"
    fixed_value "01"
    value :name, 10, filler: ?-
    empty 2
    fixed_value "!"
  end

  def george_matcher(<< _ :: binary-size(14), "george", _ :: binary >>), do: true
  def george_matcher(_), do: false
end

[
  beatles: [code: "B1", name: "george"],
  beatles: [code: "B2", name: "john"],
  beatles: [code: "B2", name: "ringo"],
  beatles: [code: "B2", name: "paul"]
]
|> BeatlesFile.write
|> IO.puts

"000B1    1AA01george----  !\n000B2    2AA01john------  !\n000B2    3AA01ringo-----  !\n000B2    4AA01paul------  !"
|> BeatlesFile.read
|> IO.inspect
|> length
|> IO.puts
