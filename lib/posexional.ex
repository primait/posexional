defmodule Posexional do
  @moduledoc """
  Posexional is a library to manage positional files in elixir.

  Positional files are the most bad and **terrifying file format** you ever want to work with, believe me, it's utter crap. Still some *web services* use this format to expose data services, and if you are here reading this, probably you are in luck like us!

  A positional file has a *format specification* like this:

  | field name | offset | length | notes                                           |
  |------------|--------|--------|-------------------------------------------------|
  | code       | 0      | 5      | request code fill with 0 and align on the right |
  | prog       | 0      | 5      | progressive number (fill with spaces)           |
  | type       | 21     | 2      | AA                                              |
  | number     | 24     | 2      | 01                                              |
  | name       | 27     | 10     | person name (fill with -)                       |
  | future use | 38     | 2      | leave empty                                     |
  | end        | 41     | 1      | !                                               |

  The expected results should be something like this:

      000B1    1AA01george----  !
      000B2    2AA01john------  !
      000B3    3AA01ringo-----  !
      000B4    4AA01paul------  !


  cool uh?

  With Posexional you can produce this file with

      alias Posexional.Field

      beatles_row = Posexional.Row.new(:beatles, [
        Field.Value.new(:code, 5, ?0, :right),
        Field.ProgressiveNumber.new(5),
        Field.Value.new(:type, 2),
        Field.Value.new(:number, 2),
        Field.Value.new(:name, 10, ?-),
        Field.Empty.new(2),
        Field.Value.new(:end, 1, ?!)
      ])

      file = Posexional.File.new([beatles_row])

      Posexional.write(file, [beatles: [
        code: "B1", type: "AA", number: "01", name: "george"
      ], beatles: [
        code: "B2", type: "AA", number: "01", name: "john"
      ], beatles: [
        code: "B2", type: "AA", number: "01", name: "ringo"
      ], beatles: [
        code: "B2", type: "AA", number: "01", name: "paul"
      ]])

  In the first part we **define the structure**. We are not saying what the content or the number of rows there will be, we are just saying that there is a row called :beatles with the named field in it.

  Then we create a Posexional.File struct and say that only the beatles row will be in there.

  Then we can call Posexional.write/2, we pass the Posexional.File struct just defined and we feed the real data that should be written there. **Just the relevant data**, The empty fields or the progressive number is managed by the library itself.

  And even better, with the Posexional.File struct that we defined, we can even **read a positional file**
  """

  @doc """
  write a positional file with the given stuct and data
  """
  @spec write(%Posexional.File{}, Keyword.t) :: binary
  def write(positional_file, values) do
    Posexional.File.write(positional_file, values)
  end

  @doc """
  same as write/2, but with a path to a new file to write the result to
  """
  @spec write_file!(%Posexional.File{}, Keyword.t, binary) :: nil
  def write_file!(positional_file, values, path) do
    Posexional.File.write_path!(positional_file, values, path)
  end

  @doc """
  read a positional stream of data with the given struct, returns a keyword list of the extracted data
  """
  @spec read(%Posexional.File{}, binary) :: Keyword.t
  def read(positional_file, content) do
    Posexional.File.read(positional_file, content)
  end

  @doc """
  same as read/2, but with a path to a file to read the stream from
  """
  @spec read_file!(%Posexional.File{}, binary) :: Keyword.t
  def read_file!(file, path) do
    content = File.read! path
    read(file, content)
  end
end
