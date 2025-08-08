defmodule Mix.Tasks.Demo.Tcp do
  @shortdoc "Automatically run TCP demo"
  @requirements ["loadpaths", "app.config", "app.start"]

  use Mix.Task
  require Logger

  def run(_args) do
    host = System.get_env("HOSTNAME")
    Logger.info("Started")
    Logger.info("In another terminal window, connect to this container with")
    Logger.info("    docker exec -it #{host} bash")
    Logger.info("And then connect to the socket with `nc 127.0.0.1 4242`")
    Logger.info("Once connected, type some text and send with ENTER")
    Logger.info("Press Ctrl-D to close the connection on the remote")
    IO.gets("Press 'ENTER' to quit")
  end
end
