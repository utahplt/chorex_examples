defmodule ZkpLogin do
  use Application

  @impl true
  def start(_type, _args) do
    Zkp.LogVerifier.start_kv_store()
    Zkp.SrpServerImpl.start_kv_store()
    {:ok, self()}
  end

  def register_log() do
    username = IO.gets("[New User] username: ") |> String.trim()
    passwd = IO.gets("[New User] password: ") |> String.trim()

    Chorex.start(Zkp.ZkpChor.Chorex,
      %{ Prover => Zkp.LogProver,
         Verifier => Zkp.LogVerifier },
      [username, passwd, :register])

    receive do
      {:chorex_return, Verifier, {:ok, userid}} -> IO.puts("User #{userid} registered.")
      {:chorex_return, Verifier, :failed} -> IO.puts("User #{username} not registered.")
    end

    receive do
      {:chorex_return, Prover, _} -> IO.puts("Prover finished.")
    end
  end

  @verification_rounds 20

  def login_log() do
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

  def register_srp() do
    username = IO.gets("[New User SRP] username: ") |> String.trim()
    password = IO.gets("[New User SRP] password: ") |> String.trim()

    Chorex.start(Zkp.SrpChor.Chorex,
      %{ SrpServer => Zkp.SrpServerImpl,
         SrpClient => Zkp.SrpClientImpl },
      [{username, password}, :register])

    receive do
      {:chorex_return, SrpServer, resp} -> IO.puts("Server responds #{inspect resp}")
    end

    receive do
      {:chorex_return, SrpClient, resp} -> IO.puts("Client responds #{inspect resp}")
    end
  end

  def login_srp() do
    Chorex.start(Zkp.SrpChor.Chorex,
      %{ SrpServer => Zkp.SrpServerImpl,
         SrpClient => Zkp.SrpClientImpl },
      [])

    receive do
      {:chorex_return, SrpServer, resp} -> IO.puts("Server responds #{inspect resp}")
    end

    receive do
      {:chorex_return, SrpClient, resp} -> IO.puts("Client responds #{inspect resp}")
    end
  end

  def go() do
    Chorex.start(Zkp.SrpChor.Chorex,
      %{ SrpServer => Zkp.SrpServerImpl,
         SrpClient => Zkp.SrpClientImpl },
      [{"alice", "foobar"}, :register])

    receive do
      {:chorex_return, SrpServer, resp} -> IO.puts("[registration] Server responds #{inspect resp}")
    end

    receive do
      {:chorex_return, SrpClient, resp} -> IO.puts("[registration] Client responds #{inspect resp}")
    end

    login_srp()
  end
end
