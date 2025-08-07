defmodule Mix.Tasks.Demo.Srp do
  @shortdoc "Automatically run SRP demo"
  @requirements ["loadpaths", "app.config", "app.start"]

  use Mix.Task
  require Logger

  defmodule NonInteractiveClientGood do
    use Zkp.SrpChor.Chorex, :srpclient

    import Zkp.SrpChor, only: [hash_things: 1]

    @impl true
    def get_id() do
      "alice"
    end

    @impl true
    def compute_secret(g, n, s, big_b, k, id) do
      passwd = "hello world"

      a = Enum.random(2..n)
      big_a = mpow(g, a, n)
      x = hash_things([id, s, passwd])
      u = hash_things([big_a, big_b])

      secret_k =
        mpow(
          (n + as_int(big_b)) - rem(as_int(k) * as_int(mpow(g, x, n)), n),
          a + as_int(u) * as_int(x),
          n
        )

      m1 = hash_things([big_a, big_b, secret_k])
      {big_a, m1, secret_k}
    end

    @impl true
    def valid_m2?(big_a, m1, k, m2) do
      hash_things([big_a, m1, k]) == m2
    end

    defdelegate mpow(a, b, c), to: :crypto, as: :mod_pow
    defdelegate as_int(n), to: :crypto, as: :bytes_to_integer

    @impl true
    def gen_verification_token(username, password, salt, g, p) do
      x = hash_things([username, salt, password])
      mpow(g, x, p)
    end
  end

  defmodule NonInteractiveClientBad do
    use Zkp.SrpChor.Chorex, :srpclient

    import Zkp.SrpChor, only: [hash_things: 1]

    @impl true
    def get_id() do
      "alice"
    end

    @impl true
    def compute_secret(g, n, s, big_b, k, id) do
      passwd = "NOT THE PASSWORD!"

      a = Enum.random(2..n)
      big_a = mpow(g, a, n)
      x = hash_things([id, s, passwd])
      u = hash_things([big_a, big_b])

      secret_k =
        mpow(
          (n + as_int(big_b)) - rem(as_int(k) * as_int(mpow(g, x, n)), n),
          a + as_int(u) * as_int(x),
          n
        )

      m1 = hash_things([big_a, big_b, secret_k])
      {big_a, m1, secret_k}
    end

    @impl true
    def valid_m2?(big_a, m1, k, m2) do
      hash_things([big_a, m1, k]) == m2
    end

    defdelegate mpow(a, b, c), to: :crypto, as: :mod_pow
    defdelegate as_int(n), to: :crypto, as: :bytes_to_integer

    @impl true
    def gen_verification_token(username, password, salt, g, p) do
      x = hash_things([username, salt, password])
      mpow(g, x, p)
    end
  end

  def run(_args) do
    Logger.info("Starting non-interactive SRP login demo")
    Logger.info("Registration: using username 'alice', password 'hello world'")
    Logger.info("You should see 'Server responds {:registered, \"alice\"}' and 'Client responds :registered'")

    Chorex.start(Zkp.SrpChor.Chorex,
                 %{ SrpServer => Zkp.SrpServerImpl,
                 SrpClient => NonInteractiveClientGood },
                 [{"alice", "hello world"}, :register])

    receive do
      {:chorex_return, SrpServer, resp} -> IO.puts("Server responds #{inspect resp}")
    end

    receive do
      {:chorex_return, SrpClient, resp} -> IO.puts("Client responds #{inspect resp}")
    end

    Logger.info("Registration successful. Attempting login with good credentials.")
    Logger.info("You should see the same value twice---this means the server and client have computed the same value.")

    Chorex.start(Zkp.SrpChor.Chorex,
      %{ SrpServer => Zkp.SrpServerImpl,
      SrpClient => NonInteractiveClientGood },
      [])

    receive do
      {:chorex_return, SrpServer, resp} -> IO.puts("Server responds #{inspect resp}")
    end

    receive do
      {:chorex_return, SrpClient, resp} -> IO.puts("Client responds #{inspect resp}")
    end

    Logger.info("Now trying to login with bad credentials.")
    Logger.info("You should see server and client rejecting the digest")

    Chorex.start(Zkp.SrpChor.Chorex,
      %{ SrpServer => Zkp.SrpServerImpl,
      SrpClient => NonInteractiveClientBad },
      [])

    receive do
      {:chorex_return, SrpServer, resp} -> IO.puts("Server responds #{inspect resp}")
    end

    receive do
      {:chorex_return, SrpClient, resp} -> IO.puts("Client responds #{inspect resp}")
    end

    Logger.info("SRP demo complete")
  end
end
