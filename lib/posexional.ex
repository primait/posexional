defmodule Posexional do
  @moduledoc """
  main module
  """
  @spec write(%Posexional.File{}, Keyword.t) :: binary
  def write(positional_file, values) do
    Posexional.File.write(positional_file, values)
  end

  @spec write_file!(%Posexional.File{}, Keyword.t, binary) :: nil
  def write_file!(positional_file, values, path) do
    Posexional.File.write_path!(positional_file, values, path)
  end

  @spec read(%Posexional.File{}, binary) :: Keyword.t
  def read(positional_file, content) do
    Posexional.File.read(positional_file, content)
  end

  @spec read_file!(%Posexional.File{}, binary) :: Keyword.t
  def read_file!(file, path) do
    content = File.read! path
    read(file, content)
  end

  def test_file_write do
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
    Posexional.write_file!(Posexional.Test.Generator.setup_file, values, "/test.txt")
  end

  def test_file_read do
    Posexional.read_file!(Posexional.Test.Generator.setup_file, "/test.txt")
  end
end
