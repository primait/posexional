defmodule Posexional.RowTest do
  use Posexional.Case, async: true
  doctest Posexional.Row

  # moduli di esempio

  defmodule RowModule do
    use PosexionalRow

    name(__MODULE__)
    guesser &__MODULE__.matcher/1
    separator "|"

    fixed_value "test"
    value :a, 8
    progressive_number :progressive, 5, filler: ?0, alignment: :right
    empty 5, filler: ?-

    def matcher(<<"test", _::binary>>), do: true
    def matcher(_), do: false
  end

  defmodule FileModule do
    use PosexionalFile

    row RowModule
  end

  defmodule OtherRowModule do
    use PosexionalRow

    import_fields_from RowModule

    guesser &__MODULE__.matcher/1
    separator "|"

    def matcher(<<"test", _::binary>>), do: true
    def matcher(_), do: false
  end

  defmodule OtherFileModule do
    use PosexionalFile

    row OtherRowModule
  end

  defmodule DefaultRowModule do
    use PosexionalRow

    name :with_defaults
    guesser &__MODULE__.matcher/1
    separator "|"

    fixed_value "defaultrow"
    value :a, 8, default: "A"

    def matcher(<<"defaultrow", _::binary>>), do: true
    def matcher(_), do: false
  end

  defmodule DefaultFileModule do
    use PosexionalFile

    row DefaultRowModule
  end

  defmodule Row1 do
    use PosexionalRow, [:as_struct]

    guesser &__MODULE__.guesser/1

    fixed_value "row1"
    value :id, 3

    def guesser("row1" <> _), do: true
    def guesser(_), do: false
  end

  defmodule Row2 do
    use PosexionalRow, [:as_struct]

    guesser &__MODULE__.guesser/1

    value :id, 4

    def guesser(content), do: not String.starts_with?(content, "row1")
  end

  defmodule StructRowFile do
    use PosexionalFile

    row Row1
    row Row2
  end

  test "fields_from to copy fields from another row" do
    from_row = Row.new(:from, [Field.Value.new(:v1, 5), Field.Value.new(:v2, 5), Field.Value.new(:v3, 5)])
    to_row = Row.new(:to, [])
    new_row = Row.fields_from(to_row, from_row)
    assert match?(%Row{}, new_row)
    assert 3 == length(new_row.fields)
  end

  test "the row module has the correct name" do
    assert RowModule == RowModule.get_row().name
  end

  test "the row module has the correct guesser" do
    assert is_function(RowModule.get_row().row_guesser)
  end

  test "the row module has the correct separator" do
    assert "|" == RowModule.get_row().separator
  end

  test "an unknown row do not match" do
    assert [
             {RowModule, [fixed_value: "test", a: "A", progressive: 1]},
             "nono|A       |00002|-----"
           ] == FileModule.read("test|A       |00001|-----\nnono|A       |00002|-----")
  end

  test "import field from another row module yields a row struct with the same fields" do
    assert OtherRowModule.get_row().fields == RowModule.get_row().fields
  end

  test "file module with imported row works" do
    assert [
             {OtherRowModule, [fixed_value: "test", a: "A", progressive: 1]},
             "nono|A       |00002|-----"
           ] == OtherFileModule.read("test|A       |00001|-----\nnono|A       |00002|-----")
  end

  test "file module with default value in the row" do
    assert "defaultrow|A       " == DefaultFileModule.write(with_defaults: [])
  end

  test "default is ignored if value is provided" do
    assert "defaultrow|B       " == DefaultFileModule.write(with_defaults: [a: "B"])
  end

  test "should parse a file as struct" do
    content =
      "row1123\n" <>
        "afoo"

    assert [
             {Posexional.RowTest.Row1, %Posexional.RowTest.Row1{}},
             {Posexional.RowTest.Row2, %Posexional.RowTest.Row2{}}
           ] = StructRowFile.read(content)
  end
end
