defmodule MeiPortugueseBot.Cache do
  use ExActor.GenServer, export: :cache

  defstart start_link, do: initial_state(:ets.new(__MODULE__, []))

  defcall lookup(key), state: table do
    case :ets.lookup(table, key) do
      [{^key, value}] -> reply(value)
      [] -> reply(false)
    end
  end

  defcast add(key, value), state: table do
    :ets.insert(table, {key, value})
    new_state(table)
  end
end
