defmodule Posexional.FileTest do
  use Posexional.Case, async: true
  doctest Posexional.File

  defmodule FileModule do
    use Posexional

    @separator "||"

    row :test do
      progressive_number :test1, 3, filler: ?0
      progressive_number :test2, 3, filler: ?0
    end
  end


  test "manage counters" do
    assert "001001||002002" === Posexional.FileTest.FileModule.write([test: [], test: []])
  end

  test "progressive fields get_counters_names" do
    assert match? [test1: _, test2: _], Posexional.File.get_counters(Posexional.FileTest.FileModule.get_file)
  end
end
