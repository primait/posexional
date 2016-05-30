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
        use Posexional

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

  In the first part we **define the structure** inside a module. We are not saying what the content or the number of rows there will be, we are just saying that there is a row called :beatles with the structure declared by the fields

  Then we can call BeatlesFile.write/1, we pass the data that should be written in the fields. **Just the relevant data**, The empty fields, the fixed values or the progressive number is managed by the library itself.

  And even better, with the same exact module, we can even **read a positional file** by calling read/1 and passing a binary string of the file content.
  """

  alias Posexional.Field

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

  @doc """
  add use Posexional on top of an elixir module to use macros to define fields
  """
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :rows, accumulate: true
      Module.register_attribute __MODULE__, :fields, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def write(values) do
        get_file
        |> Posexional.File.write(values)
      end

      def read(content) do
        get_file
        |> Posexional.File.read(content)
      end

      def get_file do
        @rows
        |> Enum.reverse
        |> Posexional.File.new(@separator)
      end
    end
  end

  @doc """
  define a row of a positional file
  """
  defmacro row(name, guesser \\ :never, do: body) do
    quote do
      this_row = Posexional.Row.new(unquote(name), [], [row_guesser: unquote(guesser)])
      unquote(body)
      @rows Posexional.Row.add_fields(this_row, Enum.reverse(@fields))
      Module.delete_attribute(__MODULE__, :fields)
    end
  end

  @doc """
  add a value field
  """
  defmacro value(name, size, opts \\ []) do
    quote do
      @fields Field.Value.new(unquote(name), unquote(size), unquote(opts))
    end
  end

  @doc """
  add an empty field
  """
  defmacro empty(size, opts \\ []) do
    quote do
      @fields Field.Empty.new(unquote(size), unquote(opts))
    end
  end

  @doc """
  add a field with a fixed value
  """
  defmacro fixed_value(v) do
    quote do
      @fields Field.FixedValue.new(unquote(v))
    end
  end

  @doc """
  add a field with a progressive_number value
  """
  defmacro progressive_number(name, size, opts \\ []) do
    quote do
      @fields Field.ProgressiveNumber.new(unquote(name), unquote(size), unquote(opts))
    end
  end
end
