defmodule Posexional.Case do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Posexional.{Field, File, Row}
    end
  end
end
