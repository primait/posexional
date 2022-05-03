defmodule Posexional.StreamFileTest do
  use Posexional.Case, async: true

  defmodule StreamFile do
    use PosexionalFile

    @separator "\n"

    row :stream_row, :always do
      value :code, 6
      value :name, 30
    end
  end

  test "Stream read file" do
    parsed_rows =
      "#{__DIR__}/files/test_file"
      |> Elixir.File.stream!([], 7)
      |> Posexional.File.stream(StreamFile.get_file())
      |> Enum.map(&elem(&1, 1))

    assert [
             [code: "000001", name: "APPLE INC"],
             [code: "000002", name: "MICROSOFT CORP"],
             [code: "000003", name: "AMAZON.COM INC"],
             [code: "000004", name: "TESLA INC"],
             [code: "000005", name: "ALPHABET INC CLASS A"],
             [code: "000006", name: "ALPHABET INC CLASS C"],
             [code: "000007", name: "NVIDIA CORP"],
             [code: "000008", name: "BERKSHIRE HATHAWAY INC"],
             [code: "000009", name: "META PLATFORMS INC"],
             [code: "000010", name: "UNITEDHEALTH GROUP"]
           ] === parsed_rows
  end
end
