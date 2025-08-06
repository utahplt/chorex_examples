defmodule Mix.Tasks.Demo.Tcp do
  @shortdoc "Automatically run TCP demo"
  @requirements ["loadpaths", "app.config", "app.start"]

  use Mix.Task

  def run(_args) do
    IO.puts("Hey look running the TCP service!")
  end
end
