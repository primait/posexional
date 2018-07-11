defmodule PosexionalTest do
  use Posexional.Case, async: true

  test "full example" do
    row = Row.new(:test, [
      Field.Value.new(:codice_impresa, 8, filler: ?0, alignment: :right),
      Field.Value.new(:data_inizio_elab, 8),
      Field.Value.new(:ora_inizio_elab, 6),
      Field.ProgressiveNumber.new(:prog, 9, filler: ?0),
      Field.Empty.new(4),
      Field.FixedValue.new("REINPIBD"),
      Field.Value.new(:codice_impresa_destinataria, 4, filler: ?0, alignment: :right),
      Field.Empty.new(3)
    ])
    end_row = Row.new(:end, [
      Field.Value.new(:codice_impresa, 8, filler: ?0, alignment: :right),
      Field.Value.new(:data_inizio_elab, 8),
      Field.Value.new(:ora_inizio_elab, 6),
      Field.ProgressiveNumber.new(:prog, 9, filler: ?0),
      Field.Value.new(:tipo_record, 4),
      Field.FixedValue.new("REINPIBD"),
      Field.Value.new(:codice_impresa_destinataria, 4, filler: ?0, alignment: :right),
      Field.Empty.new(3)
    ])
    file = File.new([row, end_row])
    values = [test: [
      codice_impresa: "899",
      data_inizio_elab: "20160524",
      ora_inizio_elab: "100000",
      codice_impresa_destinataria: "899"
    ], test: [
      codice_impresa: "899",
      data_inizio_elab: "20160524",
      ora_inizio_elab: "100000",
      codice_impresa_destinataria: "899"
    ], end: [
      codice_impresa: "899",
      data_inizio_elab: "20160524",
      ora_inizio_elab: "100000",
      codice_impresa_destinataria: "899",
      tipo_record: "FINE"
    ]]
    assert "0000089920160524100000000000001    REINPIBD0899   \n"
      <> "0000089920160524100000000000002    REINPIBD0899   \n"
      <> "0000089920160524100000000000003FINEREINPIBD0899   "
      === Posexional.write(file, values)
  end

  test "different separator" do
    row = Row.new(:test, [Field.Value.new(:code, 8, filler: ?0, alignment: :right)])
    file = File.new([row], "\n\r")
    res = Posexional.write(file, [test: [code: "1"], test: [code: "2"]])
    assert "00000001\n\r00000002" === res
  end

  test "invalid row name raises a RuntimeError" do
    row = Row.new(:test, [Field.Value.new(:code, 8, filler: ?0, alignment: :right)])
    file = File.new([row])
    assert_raise RuntimeError, fn ->
      Posexional.write(file, [not_existent: [code: "1"]])
    end
  end

  test "read a file and outputs a keyword list" do
    row = Row.new(:test, [Field.Value.new(:code, 4, filler: ?0, alignment: :right)], row_guesser: :always)
    file = File.new([row])
    assert [test: [code: "0001"], test: [code: "0002"]] === Posexional.read(file, "0001\n0002")
  end

  test "read a file and outputs a keyword list with progressive number field" do
    fields = [
      Field.Value.new(:code, 4, filler: ?0, alignment: :right),
      Field.ProgressiveNumber.new(:prog, 3, filler: ?0)
    ]
    row = Row.new(:test, fields, row_guesser: :always)
    file = File.new([row])
    assert [test: [code: "0001", prog: 1], test: [code: "0002", prog: 2]] === Posexional.read(file, "0001001\n0002002")
  end

  test "read a file with a progressive number filled with white spaces and outputs a keyword list with progressive number field" do
    fields = [
      Field.Value.new(:code, 4, filler: ?0, alignment: :right),
      Field.ProgressiveNumber.new(:prog, 3)
    ]
    row = Row.new(:test, fields, row_guesser: :always)
    file = File.new([row])
    assert [test: [code: "0001", prog: 1], test: [code: "0002", prog: 2]] === Posexional.read(file, "0001  1\n0002  2")
  end

  test "read a file with a progressive number filled with white spaces and left aligned and outputs a keyword list with progressive number field" do
    fields = [
      Field.Value.new(:code, 4, filler: ?0, alignment: :left),
      Field.ProgressiveNumber.new(:prog, 3)
    ]
    row = Row.new(:test, fields, row_guesser: :always)
    file = File.new([row])
    assert [test: [code: "0001", prog: 1], test: [code: "0002", prog: 2]] === Posexional.read(file, "0001  1\n0002  2")
  end

  test "read a file and outputs a keyword list with empty field" do
    fields = [
      Field.Value.new(:code, 4, filler: ?0, alignment: :right),
      Field.Empty.new(3),
      Field.Value.new(:label, 10, filler: ?-, alignment: :left)
    ]
    row = Row.new(:test, fields, row_guesser: :always)
    file = File.new([row])
    assert [test: [code: "0001", label: "test------"], test: [code: "0002", label: "label-----"]]
      === Posexional.read(file, "0001   test------\n0002   label-----")
  end

  test "fixed value field" do
    fields = [Field.Value.new(:code, 4, filler: ?0, alignment: :right), Field.FixedValue.new("test")]
    file = File.new([Row.new(:test, fields)])
    assert "0001test" === Posexional.write(file, [test: [code: "0001"]])
  end
end
