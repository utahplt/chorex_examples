defmodule Zkp.SrpServerImpl do
  use Zkp.SrpChor.Chorex, :srpserver

  # import Zkp.SrpChor, only: [hash_things: 1]

  @good_g 5
  # @good_p 479694587694587625877438567424477454923
  @good_p 24797447897446996546996546985674858769458769058773184769458768396529654731846923654925965579

  @user_tbl :srp_users

  def start_kv_store() do
    :ets.new(@user_tbl, [:named_table, :set, :public])
  end

  @impl true
  def register(ident, salt, token) do
    :ets.insert_new(@user_tbl, {ident, salt, token, @good_p, @good_g})
  end

  @impl true
  def get_params(), do: {gen_salt(), @good_g, @good_p}

  def gen_salt() do
    :rand.uniform(@good_p)
  end

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

    mpow((as_int(big_a) * as_int(mpow(v, u, n))), b, n)
  end

  @impl true
  def valid_m1?(a, b, k, m1) do
	hash_things([a, b, k]) == m1
  end

  @impl true
  defdelegate hash_things(lst), to: Zkp.SrpChor

  @impl true
  defdelegate as_int(n), to: :crypto, as: :bytes_to_integer

  @impl true
  defdelegate mpow(a, b, c), to: :crypto, as: :mod_pow

  @impl true
  def compute_m2(big_a, m1, secret) do
	hash_things([big_a, m1, secret])
  end
end
