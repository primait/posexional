defmodule Posexional.RowTest do
  use Posexional.Case, async: true
  doctest Posexional.Row

  test "fields_from to copy fields from another row" do
    from_row = Row.new(:from, [Field.Value.new(:v1, 5), Field.Value.new(:v2, 5), Field.Value.new(:v3, 5)])
    to_row = Row.new(:to, [])
    new_row = Row.fields_from(to_row, from_row)
    assert match?(%Row{}, new_row)
    assert 3 === length(new_row.fields)
  end

  test "the row module has the correct name" do
    assert Posexional.RowTest.RowModule === Posexional.RowTest.RowModule.get_row().name
  end

  test "the row module has the correct guesser" do
    assert is_function(Posexional.RowTest.RowModule.get_row().row_guesser)
  end

  test "the row module has the correct separator" do
    assert "|" === Posexional.RowTest.RowModule.get_row().separator
  end

  test "an unkonwn row do not match" do
    assert [
             {Posexional.RowTest.RowModule, [fixed_value: "test", a: "A", progressive: 1]},
             "nono|A       |00002|-----"
           ] === Posexional.RowTest.FileModule.read("test|A       |00001|-----\nnono|A       |00002|-----")
  end

  test "import field from another row module yields a row struct with the same fields" do
    assert Posexional.RowTest.OtherRowModule.get_row().fields === Posexional.RowTest.RowModule.get_row().fields
  end

  test "file module with imported row works" do
    assert [
             {Posexional.RowTest.OtherRowModule, [fixed_value: "test", a: "A", progressive: 1]},
             "nono|A       |00002|-----"
           ] === Posexional.RowTest.OtherFileModule.read("test|A       |00001|-----\nnono|A       |00002|-----")
  end

  test "file module with default value in the row" do
    assert "defaultrow|A       " === Posexional.RowTest.DefaultFileModule.write(with_defaults: [])
  end

  test "default is ignored if value is provided" do
    assert "defaultrow|B       " === Posexional.RowTest.DefaultFileModule.write(with_defaults: [a: "B"])
  end

  # moduli di esempio

  defmodule RowModule do
    use PosexionalRow

    name(__MODULE__)
    guesser(&__MODULE__.matcher/1)
    separator("|")

    fixed_value("test")
    value :a, 8
    progressive_number(:progressive, 5, filler: ?0, alignment: :right)
    empty(5, filler: ?-)

    def matcher(<<"test", _::binary>>), do: true
    def matcher(_), do: false
  end

  defmodule FileModule do
    use PosexionalFile

    row(Posexional.RowTest.RowModule)
  end

  defmodule OtherRowModule do
    use PosexionalRow

    import_fields_from(Posexional.RowTest.RowModule)

    guesser(&__MODULE__.matcher/1)
    separator("|")

    def matcher(<<"test", _::binary>>), do: true
    def matcher(_), do: false
  end

  defmodule OtherFileModule do
    use PosexionalFile

    row(Posexional.RowTest.OtherRowModule)
  end

  defmodule DefaultRowModule do
    use PosexionalRow

    name(:with_defaults)
    guesser(&__MODULE__.matcher/1)
    separator("|")

    fixed_value("defaultrow")
    value :a, 8, default: "A"

    def matcher(<<"defaultrow", _::binary>>), do: true
    def matcher(_), do: false
  end

  defmodule DefaultFileModule do
    use PosexionalFile

    row(Posexional.RowTest.DefaultRowModule)
  end
end
