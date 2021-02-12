defmodule Posexional.Field.TypedFieldTest do
  use Posexional.Case, async: true

  defmodule Row1 do
    use PosexionalRow, [:as_struct]

    guesser &__MODULE__.guesser/1

    fixed_value "row1"
    field :id, :id, 3
    field :binary_id, :binary_id, 3
    field :integer, :integer, 2
    field :float, :float, 6
    field :boolean, :boolean, 5
    field :string, :string, 4
    field :binary, :binary, 4

    def guesser("row1" <> _), do: true
    def guesser(_), do: false
  end

  defmodule Row2 do
    use PosexionalRow, [:as_struct]

    guesser &__MODULE__.guesser/1

    field :custom, :custom, 4, parser: &String.to_atom/1
    field :array, :array, 4, separator: ""
    field :list, :list, 7, separator: "|"
    field :decimal, :decimal, 8
    field :date, :date, 8, format_in: "{0M}{0D}{YYYY}"
    field :time, :time, 8, format_in: "%H%M%S%f"
    field :time2, :time, 6, format_in: "%H%M%S"
    field :datetime, :datetime, 14, format_in: "%d%m%Y%H%M%S", timezone: "America/Sao_Paulo"
    field :naive_dt, :naive_datetime, 23, format_in: "%d/%m/%Y@%H:%M:%S.%L"
    field :utc_dt, :utc_datetime, 23, format_in: "%Y-%m-%d %H:%M:%S.%L"

    def guesser("afoo" <> _), do: true
    def guesser(_), do: false
  end

  defmodule Row3 do
    use PosexionalRow, [:as_struct]

    guesser &__MODULE__.guesser/1

    fixed_value "row3"
    field :custom, :custom, 4

    def guesser("row3" <> _), do: true
    def guesser(_), do: false
  end

  defmodule StructRowFile do
    use PosexionalFile

    row Row1
    row Row2
    row Row3
  end

  test "should parse correctly each field type" do
    content =
      "row1123ABA00432.99falseJohn Doe\n" <>
        "afoo1234cat|dog123.45  01312021235959990745001209198807450031/12/2021@23:59:59.9992022-01-01 00:00:00.000"

    assert [
             "Elixir.Posexional.Field.TypedFieldTest.Row1": %Posexional.Field.TypedFieldTest.Row1{
               binary: "Doe",
               binary_id: "ABA",
               boolean: false,
               float: 432.99,
               id: 123,
               integer: 0,
               string: "John"
             },
             "Elixir.Posexional.Field.TypedFieldTest.Row2": %Posexional.Field.TypedFieldTest.Row2{
               array: ["1", "2", "3", "4"],
               custom: :afoo,
               date: ~D[2021-01-31],
               datetime: %DateTime{
                 year: 1988,
                 month: 9,
                 day: 12,
                 hour: 7,
                 minute: 45,
                 second: 00,
                 utc_offset: -10_800,
                 time_zone: "America/Sao_Paulo",
                 std_offset: 0,
                 zone_abbr: "-03"
               },
               decimal: 123.45,
               list: ["cat", "dog"],
               naive_dt: ~N[2021-12-31 23:59:59.999],
               time: ~T[23:59:59.99],
               time2: ~T[07:45:00],
               utc_dt: ~U[2022-01-01 00:00:00Z]
             }
           ] = StructRowFile.read(content)
  end

  test "should raise ArgumentError when given id is not valid" do
    content =
      "row1abcABA00432.99falseJohn Doe\n" <>
        "afoo1234cat|dog123.45  01312021235959990745001209198807450031/12/2021@23:59:59.9992022-01-01 00:00:00.000"

    assert_raise ArgumentError, "abc is not a valid integer. Provide option :base should it not be on 10.", fn ->
      StructRowFile.read(content)
    end
  end

  test "should raise ArgumentError when given integer is not valid" do
    content =
      "row1123ABA0a432.99falseJohn Doe\n" <>
        "afoo1234cat|dog123.45  01312021235959990745001209198807450031/12/2021@23:59:59.9992022-01-01 00:00:00.000"

    assert_raise ArgumentError, "0a is not a valid integer. Provide option :base should it not be on 10.", fn ->
      StructRowFile.read(content)
    end
  end

  test "should raise ArgumentError when given float is not valid" do
    content =
      "row1123ABA0043a.99falseJohn Doe\n" <>
        "afoo1234cat|dog123.45  01312021235959990745001209198807450031/12/2021@23:59:59.9992022-01-01 00:00:00.000"

    assert_raise ArgumentError, "43a.99 is not a valid float number.", fn ->
      StructRowFile.read(content)
    end
  end

  test "should raise ArgumentError when given boolean is not valid" do
    content =
      "row1123ABA00432.99falsoJohn Doe\n" <>
        "afoo1234cat|dog123.45  01312021235959990745001209198807450031/12/2021@23:59:59.9992022-01-01 00:00:00.000"

    assert_raise ArgumentError, "falso is not a valid boolean.", fn ->
      StructRowFile.read(content)
    end
  end

  test "should raise ArgumentError when given custom type has no parser" do
    content = "row31234"

    assert_raise ArgumentError, "Provide a :parser option as a function to customize type custom to value 1234", fn ->
      StructRowFile.read(content)
    end
  end

  test "should raise ArgumentError when given decimal is not valid" do
    content =
      "row1123ABA00432.99falseJohn Doe\n" <>
        "afoo1234cat|dog123a45  01312021235959990745001209198807450031/12/2021@23:59:59.9992022-01-01 00:00:00.000"

    assert_raise ArgumentError, "123a45 is not a valid float number.", fn ->
      StructRowFile.read(content)
    end
  end

  test "should raise ArgumentError when given date is not valid with format" do
    content =
      "row1123ABA00432.99falseJohn Doe\n" <>
        "afoo1234cat|dog123.45  0a312021235959990745001209198807450031/12/2021@23:59:59.9992022-01-01 00:00:00.000"

    assert_raise ArgumentError, "0a312021 could not be parsed as date with format {0M}{0D}{YYYY}", fn ->
      StructRowFile.read(content)
    end
  end

  test "should raise ArgumentError when given time is not valid with format" do
    content =
      "row1123ABA00432.99falseJohn Doe\n" <>
        "afoo1234cat|dog123.45  013120212A5959990745001209198807450031/12/2021@23:59:59.9992022-01-01 00:00:00.000"

    assert_raise ArgumentError, "2A595999 could not be parsed as time with format %H%M%S%f", fn ->
      StructRowFile.read(content)
    end
  end

  test "should raise ArgumentError when given datetime is not valid with format" do
    content =
      "row1123ABA00432.99falseJohn Doe\n" <>
        "afoo1234cat|dog123.45  013120212359599907450012o9198807450031/12/2021@23:59:59.9992022-01-01 00:00:00.000"

    assert_raise ArgumentError, "12o91988074500 could not be parsed as datetime with format %d%m%Y%H%M%S", fn ->
      StructRowFile.read(content)
    end
  end

  test "should raise ArgumentError when given naive_datetime is not valid with format" do
    content =
      "row1123ABA00432.99falseJohn Doe\n" <>
        "afoo1234cat|dog123.45  01312021235959990745001209198807450031/12/2o21@23:59:59.9992022-01-01 00:00:00.000"

    assert_raise ArgumentError,
                 "31/12/2o21@23:59:59.999 could not be parsed as naive_datetime with format %d/%m/%Y@%H:%M:%S.%L",
                 fn ->
                   StructRowFile.read(content)
                 end
  end

  test "should raise ArgumentError when given utc_datetime is not valid with format" do
    content =
      "row1123ABA00432.99falseJohn Doe\n" <>
        "afoo1234cat|dog123.45  01312021235959990745001209198807450031/12/2021@23:59:59.9992022-01-o1 00:00:00.000"

    assert_raise ArgumentError,
                 "2022-01-o1 00:00:00.000 could not be parsed as datetime with format %Y-%m-%d %H:%M:%S.%L",
                 fn ->
                   StructRowFile.read(content)
                 end
  end
end
