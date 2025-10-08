defmodule ChatServer.Registry do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(pid) do
    Agent.update(__MODULE__, fn list -> [pid | list] end)
  end

  def remove(pid) do
    Agent.update(__MODULE__, fn list -> List.delete(list, pid) end)
  end

  def list do
    Agent.get(__MODULE__, &(&1))
  end
end
