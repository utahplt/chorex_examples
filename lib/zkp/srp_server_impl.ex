defmodule Zkp.SrpServerImpl do
  use Zkp.SrpChor.Chorex, :srpserver

  import Zkp.SrpChor, only: [hash_things: 1]

  @good_g 5
  @good_p 479694587694587625877438567424477454923

  @user_tbl :srp_users

  def start_kv_store() do
    :ets.new(@user_tbl, [:named_table, :set, :public])
  end

  # @impl true
  # def register(ident, token) do
  #   :ets.insert_new(@user_tbl, {ident, token, @good_p, @good_g})
  # end

  @impl true
  def get_params(), do: {@good_g, @good_p}

  @impl true
  def lookup(ident) do
    case :ets.lookup(@user_tbl, ident) do
      [{^ident, salt, tok, p, g}] -> {g, p, salt, tok}
      _ -> nil
    end
  end

  @impl true
  def compute_secret(n, big_a, big_b, b, v) do
    u = hash_things([big_a, big_b])

    :crypto.mod_pow((big_a * :crypto.mod_pow(v, u, n)), b, n)
  end

  @impl true
  def valid_m1?(a, b, k, m1) do
	hash_things([a, b, k]) == m1
  end
end
