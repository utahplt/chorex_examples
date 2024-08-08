defmodule ZkpLogin do
  use Application

  @impl true
  def start(_type, _args) do
    Zkp.LogVerifier.start_kv_store()
    {:ok, self()}
  end

  def register() do
    username = IO.gets("[New User] username: ")
    passwd = IO.gets("[New User] password: ")

    Chorex.start(Zkp.ZkpChor.Chorex,
      %{ Prover => Zkp.LogProver,
         Verifier => Zkp.LogVerifier },
      [username, passwd, :register])

    receive do
      {:chorex_return, Verifier, {:ok, userid}} -> IO.puts("User #{userid} registered.")
    end

    receive do
      {:chorex_return, Prover, :ok} -> IO.puts("Prover finished.")
    end
  end

  @verification_rounds 20

  def login() do
    Chorex.start(Zkp.ZkpChor.Chorex,
      %{ Prover => Zkp.LogProver,
         Verifier => Zkp.LogVerifier },
      [@verification_rounds])

    receive do
      {:chorex_return, Verifier, resp} -> IO.puts("Verifier responds #{inspect resp}")
    end

    receive do
      {:chorex_return, Prover, resp} -> IO.puts("Prover responds #{inspect resp}")
    end
  end
end
