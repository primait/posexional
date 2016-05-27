defmodule Posexional.Test.Generator do
  def setup_file do
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
    ], :always)
    end_row = Row.new(:end, [
      FieldValue.new(:codice_impresa, 8, ?0, :right),
      FieldValue.new(:data_inizio_elab, 8),
      FieldValue.new(:ora_inizio_elab, 6),
      progressive_number,
      FieldValue.new(:tipo_record, 4),
      FieldValue.new(:codice_flusso, 8),
      FieldValue.new(:codice_impresa_destinataria, 4, ?0, :right),
      FieldEmpty.new(3)
    ], :always)
    Posexional.File.new([row, end_row])
  end
end
