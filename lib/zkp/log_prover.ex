defmodule Zkp.LogProver do
  use Zkp.ZkpChor.Chorex, :prover

  @impl true
  def get_ident() do
    IO.gets("Username: ")
  end

  @impl true
  def get_secret(username) do
    passwd = IO.gets("Password: ")
    :crypto.hash(:sha256, passwd <> username)
  end

  @impl true
  def notify_progress(n) do
    IO.puts("[Prover] notified that #{n} rounds of verification remain")
  end
end
