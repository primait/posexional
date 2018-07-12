defmodule PosexionalFile do
  @moduledoc """
  macros for defining file modules
  """

  @doc """
  add use Posexional on top of an elixir module to use macros to define fields
  """
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      import PosexionalRow
      @separator "\n"
      Module.register_attribute(__MODULE__, :rows, accumulate: true)
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def write(values) do
        get_file()
        |> Posexional.File.write(values)
      end

      def write_file!(values, file) do
        get_file()
        |> Posexional.File.write_path!(values, file)
      end

      def read(content) do
        get_file()
        |> Posexional.File.read(content)
      end

      def get_file do
        @rows
        |> Enum.reverse()
        |> Posexional.File.new(@separator)
      end
    end
  end

  @doc """
  define a row of a positional file
  """
  defmacro row(name, do: body) do
    quote do
      this_row = Posexional.Row.new(unquote(name), [])
      unquote(body)
      @rows Posexional.Row.add_fields(this_row, Enum.reverse(@fields))
      Module.delete_attribute(__MODULE__, :fields)
    end
  end

  defmacro row(name, guesser, do: body) do
    quote do
      this_row = Posexional.Row.new(unquote(name), [], row_guesser: unquote(guesser))
      unquote(body)
      @rows Posexional.Row.add_fields(this_row, Enum.reverse(@fields))
      Module.delete_attribute(__MODULE__, :fields)
    end
  end

  defmacro row(row_module) do
    quote do
      @rows unquote(row_module).get_row
    end
  end
end
