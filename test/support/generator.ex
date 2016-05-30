defmodule Posexional.Test.Generator do
  alias Posexional.{Field,Row}

  def setup_file do
    progressive_number = Field.ProgressiveNumber.new(:prog, 9, filler: ?0)
    row = Row.new(:test, [
      Field.Value.new(:codice_impresa, 8, filler: ?0, alignment: :right),
      Field.Value.new(:data_inizio_elab, 8),
      Field.Value.new(:ora_inizio_elab, 6),
      progressive_number,
      Field.Empty.new(4),
      Field.Value.new(:codice_flusso, 8),
      Field.Value.new(:codice_impresa_destinataria, 4, filler: ?0, alignment: :right),
      Field.Empty.new(3)
    ], :always)
    end_row = Row.new(:end, [
      Field.Value.new(:codice_impresa, 8, filler: ?0, alignment: :right),
      Field.Value.new(:data_inizio_elab, 8),
      Field.Value.new(:ora_inizio_elab, 6),
      progressive_number,
      Field.Value.new(:tipo_record, 4),
      Field.Value.new(:codice_flusso, 8),
      Field.Value.new(:codice_impresa_destinataria, 4, filler: ?0, alignment: :right),
      Field.Empty.new(3)
    ], :always)
    Posexional.File.new([row, end_row])
  end
end
