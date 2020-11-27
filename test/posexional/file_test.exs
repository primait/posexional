defmodule Posexional.FileTest do
  use Posexional.Case, async: true
  doctest PosexionalFile, import: true

  defmodule FileModule do
    use PosexionalFile

    @separator "||"

    row :test do
      fixed_value "test"
      value :test_value, 5, filler: ?-
      progressive_number :test1, 3, filler: ?0
      progressive_number :test2, 3, filler: ?0
    end
  end

  test "manage counters" do
    assert "testtest-001001||test-----002002" == FileModule.write(test: [test_value: "test"], test: [])
  end

  test "value to long" do
    assert_raise RuntimeError,
                 "The value test value is too long for the test_value field. The maximum size is 5 while the value is 10",
                 fn ->
                   FileModule.write(test: [test_value: "test value"], test: [])
                 end
  end

  test "progressive fields get_counters_names" do
    assert match?([test1: _, test2: _], Posexional.File.get_counters(FileModule.get_file()))
  end

  test "file encoding write" do
    assert "testàÈìÒù001001||test-----002002" == FileModule.write(test: [test_value: "àÈìÒù"], test: [])
  end

  test "file encoding write_path" do
    tmp_file = "/tmp/tmp.txt"

    assert {:ok, tmp_file} == FileModule.write_file!([test: [test_value: "àÈìÒù"], test: []], tmp_file)

    assert "testàÈìÒù001001||test-----002002" == Elixir.File.read!(tmp_file)
  end

  defmodule FileModuleWithGuesser do
    use PosexionalFile

    @separator "||"

    row :test, :always do
      fixed_value "te"
      fixed_value "st"
      value :test_value, 5, filler: ?-
      progressive_number :test1, 3, filler: ?0
      progressive_number :test2, 3, filler: ?0
    end
  end

  test "parse a file works as expected" do
    assert [
             test: [fixed_value: "te", fixed_value: "st", test_value: "test", test1: 1, test2: 1],
             test: [fixed_value: "te", fixed_value: "st", test_value: nil, test1: 2, test2: 2]
           ] == FileModuleWithGuesser.read("testtest-001001||test-----002002")
  end
end
