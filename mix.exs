defmodule ChorexExamples.MixProject do
  use Mix.Project

  def project do
    [
      app: :chorex_examples,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # mod: {TcpServer, []},
      mod: {ZkpLogin, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:chorex, "~> 0.2.0"}
      {:chorex, git: "https://github.com/utahplt/chorex.git"}
    ]
  end
end
