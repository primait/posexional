defmodule PosexionalTest do
  use Posexional.Case, async: true

  test "example 1" do
    row = Row.new(:ania, [
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
    values = [ania: [
      codice_impresa: "899",
      data_inizio_elab: "20160524",
      ora_inizio_elab: "100000",
      codice_flusso: "REINPIBD",
      codice_impresa_destinataria: "899"
    ], ania: [
      codice_impresa: "899",
      data_inizio_elab: "20160524",
      ora_inizio_elab: "100000",
      codice_flusso: "REINPIBD",
      codice_impresa_destinataria: "899"
    ]]
    assert "0000089920160524100000000000001    REINPIBD0899   \n0000089920160524100000000000002    REINPIBD0899   "
      === Posexional.write(file, values)
  end
end
