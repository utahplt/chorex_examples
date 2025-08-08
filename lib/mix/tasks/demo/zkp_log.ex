defmodule Mix.Tasks.Demo.ZkpLog do
  @shortdoc "Automatically run ZKP LOG demo"
  @requirements ["loadpaths", "app.config", "app.start"]

  use Mix.Task
  require Logger

  defmodule NonInteractiveProverGood do
    use Zkp.ZkpChor.Chorex, :prover

    @impl true
    def get_ident() do
      "alice"
    end

    @impl true
    def get_secret(username) do
      passwd = "hello world"
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

  defmodule NonInteractiveProverBad do
    use Zkp.ZkpChor.Chorex, :prover

    @impl true
    def get_ident() do
      "alice"
    end

    @impl true
    def get_secret(username) do
      passwd = "NOT MY PASSWORD"
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

  def run(_args) do
    Logger.info("Starting non-interactive ZKP logarithm login demo")
    Logger.info("Registration: using username 'alice', password 'hello world'")

    Logger.info(
      "You should see 'User alice registered."
    )

    Chorex.start(
      Zkp.ZkpChor.Chorex,
      %{ Prover => NonInteractiveProverGood, Verifier => Zkp.LogVerifier },
      ["alice", "hello world", :register]
    )

    receive do
      {:chorex_return, Verifier, {:ok, userid}} -> IO.puts("User #{userid} registered.")
      {:chorex_return, Verifier, :failed} -> IO.puts("User not registered.")
    end
    receive do
      {:chorex_return, Prover, _} -> IO.puts("Prover finished.")
    end

    Logger.info("Registration done. Attempting login with good credentials.")

    Logger.info(
      "You should see that login is successful after 5 challenge rounds."
    )

    Chorex.start(
      Zkp.ZkpChor.Chorex,
      %{ Prover => NonInteractiveProverGood,
      Verifier => Zkp.LogVerifier },
      [5])

    receive do
      {:chorex_return, Verifier, resp} -> IO.puts("Verifier responds #{inspect resp}")
    end

    receive do
      {:chorex_return, Prover, resp} -> IO.puts("Prover responds #{inspect resp}")
    end

    Logger.info("Now trying to login with bad credentials.")
    Logger.info("You should see a failure.")

    Chorex.start(
      Zkp.ZkpChor.Chorex,
      %{ Prover => NonInteractiveProverBad,
      Verifier => Zkp.LogVerifier },
      [5])

    receive do
      {:chorex_return, Verifier, resp} -> IO.puts("Verifier responds #{inspect resp}")
    end

    receive do
      {:chorex_return, Prover, resp} -> IO.puts("Prover responds #{inspect resp}")
    end

    Logger.info("ZKP Logarithm demo complete")
  end
end
