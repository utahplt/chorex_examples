defmodule Zkp.UserRegistry do
  use GenServer

  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  def init(_) do
	tbl = :ets.new(:users_registry, [:set, :public])
    {:ok, tbl}
  end

  def handle_call({:lookup, k}, _from, tbl) do
    resp =
      case :ets.lookup(tbl, k) do
        [{^k, v}] -> {:ok, v}
        _ -> :error
      end

    {:reply, resp, tbl}
  end

  def handle_call({:set, k, v}, _from, tbl) do
    :ets.insert_new(tbl, {k, v})
    {:reply, :ok, tbl}
  end
end
