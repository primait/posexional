defmodule Posexional.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Posexional.{File,Row}
      alias Posexional.Field
    end
  end
end
