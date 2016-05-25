defmodule PosexionalTest do
  use Posexional.Case, async: true

  test "example 1" do
    codice_impresa = Field.new(:codice_impresa, 8, ?0, :right)
    data_inizio_elab = Field.new(:data_inizio_elab, 8)
    ora_inizio_elab = Field.new(:ora_inizio_elab, 6)
    progressivo = Field.new(:ora_inizio_elab, 6)
    tipo_record = Field.new(:tipo_record, 4)
    codice_flusso = Field.new(:codice_flusso, 8)
    codice_impresa_destinataria = Field.new(:codice_impresa_destinataria, 4, ?0, :right)
    blank_testata = Field.new(:blank_testata, 3)
    row = Row.new(:ania, [codice_impresa, data_inizio_elab, ora_inizio_elab, progressivo, tipo_record, codice_flusso, codice_impresa_destinataria, blank_testata])

    IO.inspect Row.output(row, [codice_impresa: "899"])
  end
end
