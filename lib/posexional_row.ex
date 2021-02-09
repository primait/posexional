defmodule PosexionalRow do
  @moduledoc """
  macros for defining row modules
  """

  alias Posexional.Field

  @doc """
  add use Posexional on top of an elixir module to use macros to define fields
  """
  defmacro __using__(opts \\ []) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      @name __MODULE__
      @guesser :never
      @separator ""
      @struct_module if Enum.member?(unquote(opts), :as_struct), do: __MODULE__
      @before_compile unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      if not is_nil(@struct_module) do
        defstruct @fields
                  |> Enum.filter(&(&1.__struct__ in [Posexional.Field.TypedField, Posexional.Field.Value]))
                  |> Enum.map(&Map.get(&1, :name))
      end

      def get_row do
        Posexional.Row.new(
          @name,
          Enum.reverse(@fields),
          row_guesser: @guesser,
          separator: @separator,
          struct_module: @struct_module
        )
      end
    end
  end

  @doc """
  sets the row name, if no name is provided the module name will be used
  """
  defmacro name(row_name) do
    quote do
      @name unquote(row_name)
    end
  end

  @doc """
  sets the row matcher
  """
  defmacro guesser(func) do
    quote do
      @guesser unquote(func)
    end
  end

  @doc """
  sets the row separator
  """
  defmacro separator(row_separator) do
    quote do
      @separator unquote(row_separator)
    end
  end

  @doc """
  add a value field
  """
  defmacro value(field_name, size, opts \\ []) do
    quote do
      @fields Field.Value.new(unquote(field_name), unquote(size), unquote(opts))
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
  defmacro fixed_value v do
    quote do
      @fields Field.FixedValue.new(unquote(v))
    end
  end

  @doc """
  add a field with a progressive_number value
  """
  defmacro progressive_number field_name, size, opts \\ [] do
    quote do
      @fields Field.ProgressiveNumber.new(unquote(field_name), unquote(size), unquote(opts))
    end
  end

  @doc """
  add all fields from another row module
  """
  defmacro import_fields_from(module_name) do
    quote do
      Enum.each(unquote(module_name).get_row.fields, fn field ->
        @fields field
      end)
    end
  end

  @doc """
  add a field
  """
  defmacro field(field_name, type, size, opts \\ []) do
    quote do
      @fields Field.TypedField.new(unquote(field_name), unquote(type), unquote(size), unquote(opts))
    end
  end
end
