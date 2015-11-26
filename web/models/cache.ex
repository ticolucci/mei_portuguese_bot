defmodule MeiPortugueseBot.Cache do
  use ExActor.GenServer

  # defstart start_link, do: initial_state(:ets.new(__MODULE__, []))
  defstart start_link, do: initial_state(:ets.new(__MODULE__, []))

  defcall check2(url), state: table do
    case :ets.lookup(table, url) do
      [{^url, long}] -> reply(long)
      [] -> reply(false)
    end
  end

  defcall check(url), state: table do
    reply(:ets.lookup(table, url))
  end

  defcast add(short, long), state: table do
    :ets.insert(table, {short, long})
    new_state(table)
  end
end