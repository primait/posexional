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
end
