defmodule Posexional.Counter do
  @moduledoc """
  A simple GenServer to manage the counters.

  Idea for the future, put an agent in the file struct and use a simple function
  """
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :posexional_counter)
  end

  def init(_) do
    {:ok, 1}
  end

  def reset do
    GenServer.cast(:posexional_counter, :reset)
  end

  def next do
    GenServer.call(:posexional_counter, :next)
  end

  def handle_cast(:reset, _) do
    {:noreply, 1}
  end

  def handle_call(:next, _from, actual_value) do
    {:reply, actual_value, actual_value + 1}
  end
end
