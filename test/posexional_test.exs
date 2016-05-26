defmodule PosexionalTest do
  use Posexional.Case, async: true

  test "full example" do
    row = Row.new(:test, [
      FieldValue.new(:codice_impresa, 8, ?0, :right),
      FieldValue.new(:data_inizio_elab, 8),
      FieldValue.new(:ora_inizio_elab, 6),
      FieldProgressiveNumber.new(9, ?0),
      FieldEmpty.new(4),
      FieldValue.new(:codice_flusso, 8),
      FieldValue.new(:codice_impresa_destinataria, 4, ?0, :right),
      FieldEmpty.new(3)
    ])
    file = File.new([row])
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
    ]]
    assert "0000089920160524100000000000001    REINPIBD0899   \n0000089920160524100000000000002    REINPIBD0899   "
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
    row = Row.new(:test, [FieldValue.new(:code, 4, ?0, :right)], "", fn _ -> true end)
    file = File.new([row])
    assert [test: [code: "1"], test: [code: "2"]] === Posexional.read(file, "0001\n0002")
  end
end
