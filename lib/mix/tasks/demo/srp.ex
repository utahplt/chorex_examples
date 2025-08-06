defmodule Mix.Tasks.Demo.Srp do
  @shortdoc "Automatically run SRP demo"
  @requirements ["loadpaths", "app.config", "app.start"]

  use Mix.Task

  def run(_args) do
    IO.puts("Hey look running the SRP demo!")
  end
end
