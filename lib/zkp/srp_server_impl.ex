defmodule Zkp.SrpServerImpl do
  use Zkp.SrpChor.Chorex, :srpserver

  # import Zkp.SrpChor, only: [hash_things: 1]

  @good_g 5
  # @good_p 479694587694587625877438567424477454923
  # @good_p 24797447897446996546996546985674858769458769058773184769458768396529654731846923654925965579
  @good_p 2027

  @user_tbl :srp_users

  def start_kv_store() do
    :ets.new(@user_tbl, [:named_table, :set, :public])
  end

  @impl true
  def register(ident, salt, token) do
    {ident, salt, token, @good_p, @good_g} |> IO.inspect(label: "[server] ident salt tok n g")
    :ets.insert_new(@user_tbl, {ident, salt, token, @good_p, @good_g})
  end

  @impl true
  def get_params(), do: {gen_salt(), @good_g, @good_p}

  def gen_salt() do
    # :rand.uniform(@good_p)
    42
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
    big_a = as_int(big_a)
    big_b = as_int(big_b)
    u = hash_things([big_a, big_b])
    # IO.inspect(as_int(u), label: "[server] u")

    # IO.inspect({as_int(big_a), as_int(v), as_int(u), b, n}, label: "[server] {big_a, v, u, b n}")

    secret_k = mpow((as_int(big_a) * as_int(mpow(v, u, n))), b, n) |> as_int()

    # IO.inspect(as_int(secret_k), label: "[server] secret_k")
    big_a = as_int(big_a)
    big_b = as_int(big_b)
    u = as_int(u)
    v = as_int(v)

    IO.puts("[server] A: #{big_a}, b: #{b}, B: #{big_b}, u: #{u}, v: #{v}, secret: #{secret_k}")
    secret_k
  end

  @impl true
  def valid_m1?(a, b, k, m1) do
	hash_things([a, b, k]) == m1
  end

  @impl true
  defdelegate hash_things(lst), to: Zkp.SrpChor

  @impl true
  def as_int(n) when is_integer(n), do: n
  def as_int(n) when is_binary(n), do: :crypto.bytes_to_integer(n)
  # defdelegate as_int(n), to: :crypto, as: :bytes_to_integer

  @impl true
  defdelegate mpow(a, b, c), to: :crypto, as: :mod_pow

  @impl true
  def compute_m2(big_a, m1, secret) do
	hash_things([big_a, m1, secret])
  end
end
