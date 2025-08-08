defmodule Mix.Tasks.Demo.Tcp do
  @shortdoc "Automatically run TCP demo"
  @requirements ["loadpaths", "app.config", "app.start"]

  use Mix.Task
  require Logger

  def run(_args) do
    Logger.info("Starting up the TCP handler...")
    ChorexExamples.start_server()
    Logger.info("Started; connect in another terminal window with `nc localhost 4242`")
    IO.gets("Press 'ENTER' to quit")
  end
end
