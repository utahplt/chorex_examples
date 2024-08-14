defmodule Zkp.SrpServerImpl do
  use Zkp.SrpChor.Chorex, :srpserver

  import Zkp.SrpChor, only: [hash_things: 1]

  @good_g 5
  @good_n 24_797_447_897_446_996_546_996_546_985_674_858_769_458_769_058_773_184_769_458_768_396_529_654_731_846_923_654_925_965_579
  # @good_n 479694587694587625877438567424477454923
  # @good_n 2027

  @user_tbl :srp_users

  def start_kv_store() do
    :ets.new(@user_tbl, [:named_table, :set, :public])
  end

  @impl true
  def register(ident, salt, token) do
    {ident, salt, token, @good_n, @good_g}
    :ets.insert_new(@user_tbl, {ident, salt, token, @good_n, @good_g})
  end

  @impl true
  def get_params(), do: {gen_salt(), @good_g, @good_n}

  def gen_salt() do
    :rand.uniform(@good_n)
  end

  @impl true
  def lookup(ident) do
    case :ets.lookup(@user_tbl, ident) do
      [{^ident, salt, tok, n, g}] -> {g, n, salt, tok}
      _ -> nil
    end
  end

  @impl true
  def gen_parameters(g, n, tok) do
    k = hash_things([g, n])
    b_secret = Enum.random(2..n)
    big_b = mpow(as_int(mpow(g, b_secret, n)) + as_int(k) * as_int(tok), 1, n)

    {k, b_secret, big_b}
  end

  @impl true
  def compute_secret(n, big_a, big_b, b, v) do
    u = hash_things([big_a, big_b])
    big_a = as_int(big_a)

    mpow(big_a * as_int(mpow(v, u, n)), b, n)
  end

  @impl true
  def valid_m1?(a, b, k, m1) do
    hash_things([a, b, k]) == m1
  end

  defdelegate as_int(n), to: :crypto, as: :bytes_to_integer

  defdelegate mpow(a, b, c), to: :crypto, as: :mod_pow

  @impl true
  def compute_m2(big_a, m1, secret) do
    hash_things([big_a, m1, secret])
  end
end
