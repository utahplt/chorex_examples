defmodule Zkp.LogProver do
  use Zkp.ZkpChor.Chorex, :prover

  @impl true
  def get_ident() do
    IO.gets("[Login] username: ") |> String.trim()
  end

  @impl true
  def get_secret(username) do
    passwd = IO.gets("[Login] password: ") |> String.trim()
    :crypto.hash(:sha256, passwd <> username)
  end

  @impl true
  def gen_verification_token(username, password, g, p) do
    :crypto.mod_pow(g, :crypto.hash(:sha256, password <> username), p)
  end

  @impl true
  def notify_progress(n) do
    IO.puts("[Prover] verified; #{n} rounds of verification remain")
  end
end
