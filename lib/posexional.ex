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

  With Posexional you can produce this file by defining a module that use Posexional

      defmodule BeatlesFile do
        use PosexionalFile

        @separator "\\n"

        row :beatles do
          value :code, 5, filler: ?0, alignment: :right
          progressive_number :code, 5
          fixed_value "AA"
          fixed_value "01"
          value :name, 10, filler: ?-
          empty 2
          fixed_value "!"
        end
      end

  and then use it in your code

      BeatlesFile.write([
        beatles: [code: "B1", name: "george"],
        beatles: [code: "B2", name: "john"],
        beatles: [code: "B2", name: "ringo"],
        beatles: [code: "B2", name: "paul"]
      ])

  In the first part we **define the structure** inside a module. We are not saying what the content or the number of
  rows there will be, we are just saying that there is a row called :beatles with the structure declared by the fields.

  Then we can call BeatlesFile.write/1, we pass the data that should be written in the fields. **Just the relevant
  data**, The empty fields, the fixed values or the progressive number is managed by the library itself.

  The write/1 function accept a keyword list with the row name as key, and a keyword list of {field name, field value}
  of data. If some data is bigger than the field size an error is thrown.

  With the same exact module, we can even **read a positional file** by calling read/1 and passing
  a binary string of the file content.

  There is only one thing to notice, when we write a file we **can be declarative** and say what row we want to write,
  as well as the data we want in it. On the other hand, while reading a positional file, we don't know which rows we
  are reading, so we need to tell in some way to every row how it is recognized, so that the parser is able to do its
  job

  Since we only have a row type (the beatles one) we can just say to the module to always match the beatles row, as
  simple as

      defmodule BeatlesFile do
        use PosexionalFile

        @separator "\\n"

        row :beatles, :always do # add :always here to always match this row while reading
          value :code, 5, filler: ?0, alignment: :right
          progressive_number :code, 5
          fixed_value "AA"
          fixed_value "01"
          value :name, 10, filler: ?-
          empty 2
          fixed_value "!"
        end
      end

  :always is a special type that always match, you could also pass :never (not so useful!) and, to gain total control
  over the choice, a function with a single argument(the full row content) to match some data inside of it.

  Now we are able to parse a positional file

      iex>~s<000B1    1AA01george----  !
      ...>000B2    2AA01john------  !
      ...>000B2    3AA01ringo-----  !
      ...>000B2    4AA01paul------  !>
      ...>|> BeatlesFile.read()
      [beatles: [code: "B1", code: 1, fixed_value: "AA", fixed_value: "01",
        name: "george", fixed_value: "!"],
       beatles: [code: "B2", code: 2, fixed_value: "AA", fixed_value: "01",
        name: "john", fixed_value: "!"],
       beatles: [code: "B2", code: 3, fixed_value: "AA", fixed_value: "01",
        name: "ringo", fixed_value: "!"],
       beatles: [code: "B2", code: 4, fixed_value: "AA", fixed_value: "01",
        name: "paul", fixed_value: "!"]]

    positional files cool again!!! Well no...they still sucks...but a little less.
  """

  @doc """
  write a positional file with the given stuct and data
  """
  @spec write(%Posexional.File{}, Keyword.t()) :: binary
  def write(positional_file, values) do
    Posexional.File.write(positional_file, values)
  end

  @doc """
  same as write/2, but with a path to a new file to write the result to
  """
  @spec write_file!(%Posexional.File{}, Keyword.t(), binary) :: nil
  def write_file!(positional_file, values, path) do
    Posexional.File.write_path!(positional_file, values, path)
  end

  @doc """
  read a positional stream of data with the given struct, returns a keyword list of the extracted data
  """
  @spec read(%Posexional.File{}, binary) :: Keyword.t()
  def read(positional_file, content) do
    Posexional.File.read(positional_file, content)
  end

  @doc """
  same as read/2, but with a path to a file to read the stream from
  """
  @spec read_file!(%Posexional.File{}, binary) :: Keyword.t()
  def read_file!(file, path) do
    content = File.read!(path)
    read(file, content)
  end
end
