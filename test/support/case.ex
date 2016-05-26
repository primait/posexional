defmodule Posexional.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Posexional.{File,Row,FieldValue,FieldEmpty,FieldProgressiveNumber}
    end
  end
end
