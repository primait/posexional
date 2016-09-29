defmodule Posexional.BigFilesTest do
  use ExUnit.Case, async: true

  defmodule BigFile do
    use PosexionalFile

    @separator "\n"

    row :beatles do
      progressive_number :code, 10, filler: ?-
      fixed_value "AA"
      fixed_value "01"
      fixed_value "!"
      value :code, 500, filler: ?0, alignment: :right
    end
  end

  @tag :experiments
  test "many rows" do
    rows = 1..100_000
    |> Stream.map(fn num ->
      {:beatles, [code: to_string(num)]}
    end)

    Posexional.BigFilesTest.BigFile.write_file!(rows, "/tmp/test_posexional")
  end
end
