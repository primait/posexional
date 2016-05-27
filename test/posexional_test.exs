defmodule PosexionalTest do
  use Posexional.Case, async: true

  test "full example" do
    progressive_number = FieldProgressiveNumber.new(9, ?0)
    row = Row.new(:test, [
      FieldValue.new(:codice_impresa, 8, ?0, :right),
      FieldValue.new(:data_inizio_elab, 8),
      FieldValue.new(:ora_inizio_elab, 6),
      progressive_number,
      FieldEmpty.new(4),
      FieldValue.new(:codice_flusso, 8),
      FieldValue.new(:codice_impresa_destinataria, 4, ?0, :right),
      FieldEmpty.new(3)
    ])
    end_row = Row.new(:end, [
      FieldValue.new(:codice_impresa, 8, ?0, :right),
      FieldValue.new(:data_inizio_elab, 8),
      FieldValue.new(:ora_inizio_elab, 6),
      progressive_number,
      FieldValue.new(:tipo_record, 4),
      FieldValue.new(:codice_flusso, 8),
      FieldValue.new(:codice_impresa_destinataria, 4, ?0, :right),
      FieldEmpty.new(3)
    ])
    file = File.new([row, end_row])
    values = [test: [
      codice_impresa: "899",
      data_inizio_elab: "20160524",
      ora_inizio_elab: "100000",
      codice_flusso: "REINPIBD",
      codice_impresa_destinataria: "899"
    ], test: [
      codice_impresa: "899",
      data_inizio_elab: "20160524",
      ora_inizio_elab: "100000",
      codice_flusso: "REINPIBD",
      codice_impresa_destinataria: "899"
    ], end: [
      codice_impresa: "899",
      data_inizio_elab: "20160524",
      ora_inizio_elab: "100000",
      codice_flusso: "REINPIBD",
      codice_impresa_destinataria: "899",
      tipo_record: "FINE"
    ]]
    assert "0000089920160524100000000000001    REINPIBD0899   \n0000089920160524100000000000002    REINPIBD0899   \n0000089920160524100000000000003FINEREINPIBD0899   "
      === Posexional.write(file, values)
  end

  test "different separator" do
    row = Row.new(:test, [FieldValue.new(:code, 8, ?0, :right)])
    file = File.new([row], "\n\r")
    res = Posexional.write(file, [test: [code: "1"], test: [code: "2"]])
    assert "00000001\n\r00000002" === res
  end

  test "invalid row name raises a RuntimeError" do
    row = Row.new(:test, [FieldValue.new(:code, 8, ?0, :right)])
    file = File.new([row])
    assert_raise RuntimeError, fn ->
      Posexional.write(file, [not_existent: [code: "1"]])
    end
  end

  test "read a file and outputs a keyword list" do
    row = Row.new(:test, [FieldValue.new(:code, 4, ?0, :right)], row_guesser: :always)
    file = File.new([row])
    assert [test: [code: "1"], test: [code: "2"]] === Posexional.read(file, "0001\n0002")
  end

  test "read a file and outputs a keyword list with progressive number field" do
    fields = [
      FieldValue.new(:code, 4, ?0, :right),
      FieldProgressiveNumber.new(3, ?0)
    ]
    row = Row.new(:test, fields, row_guesser: :always)
    file = File.new([row])
    assert [test: [code: "1"], test: [code: "2"]] === Posexional.read(file, "0001001\n0002002")
  end

  test "read a file and outputs a keyword list with empty field" do
    fields = [
      FieldValue.new(:code, 4, ?0, :right),
      FieldEmpty.new(3),
      FieldValue.new(:label, 10, ?-, :left)
    ]
    row = Row.new(:test, fields, row_guesser: :always)
    file = File.new([row])
    assert [test: [code: "1", label: "test"], test: [code: "2", label: "label"]]
      === Posexional.read(file, "0001   test------\n0002   label-----")
  end
end
