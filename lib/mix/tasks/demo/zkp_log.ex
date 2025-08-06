defmodule Mix.Tasks.Demo.ZkpLog do
  @shortdoc "Automatically run ZKP LOG demo"
  @requirements ["loadpaths", "app.config", "app.start"]

  use Mix.Task

  def run(_args) do
    IO.puts("Hey look running the ZKP_LOG demo!")
  end
end
