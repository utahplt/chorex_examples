defmodule Zkp.LogVerifier do
  use Zkp.ZkpChor.Chorex, :verifier

  @good_g 5
  @good_p 479694587694587625877438567424477454923

  @user_tbl :users_registry

  def start_kv_store() do
    :ets.new(@user_tbl, [:named_table, :set, :public])
  end

  @impl true
  def register(ident, token) do
    :ets.insert_new(@user_tbl, {ident, token, @good_p, @good_g})
  end

  @impl true
  def get_params(), do: {@good_g, @good_p}

  @impl true
  def lookup(ident) do
    case :ets.lookup(@user_tbl, ident) do
      [{^ident, tok, p, g}] -> {tok, p, g}
      _ -> nil
    end
  end

  @impl true
  def challenge_type() do
	Enum.random([:r, :xr_modp])
  end

  @impl true
  def verify_round(c, r, p, g) do
    c == :crypto.mod_pow(g, r, p)
  end

  defdelegate as_int(n), to: :crypto, as: :bytes_to_integer
  defdelegate mpow(a, b, c), to: :crypto, as: :mod_pow

  @impl true
  def verify_round(c, xr_modp, y, p, g) do
    mpow(g, xr_modp, p) == mpow(as_int(c) * as_int(y), 1, p)
  end
end
