defmodule Zkp.LogVerifier do
  use Zkp.ZkpChor.Chorex, :verifier

  @good_g 5
  @good_p 479694587694587625877438567424477454923

  @user_tbl :users_registry

  def start_kv_store() do
    :ets.new(@user_tbl, [:named_table, :set, :public])
  end

  @impl true
  def register(ident, secret) do
    verification_token = :crypto.mod_pow(@good_g, secret, @good_p)
    :ets.insert_new(@user_tbl, {ident, verification_token, @good_p, @good_g})
    {:ok, ident}
  end

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
    |> IO.inspect(label: "[verifying r]")
  end

  @impl true
  def verify_round(c, xr_modp, y, p, g) do
    IO.inspect(c, label: "c")
    IO.inspect(xr_modp, label: "xr_modp")
    IO.inspect(y, label: "y")
    IO.inspect(p, label: "p")
    IO.inspect(g, label: "g")
    :crypto.mod_pow(g, xr_modp, p) |> IO.inspect(label: "g^(x+r mod p-1) mod p")
    :crypto.mod_pow(:crypto.bytes_to_integer(c) * :crypto.bytes_to_integer(y), 1, p) |> IO.inspect(label: "(c * y) mod p")
    :crypto.mod_pow(g, xr_modp, p) == :crypto.mod_pow(:crypto.bytes_to_integer(c) * :crypto.bytes_to_integer(y), 1, p)
    |> IO.inspect(label: "[verifying (x + r mod (p - 1))]")
  end
end
