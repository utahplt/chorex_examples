defmodule Tcp.AccepterPoolImpl do
  use Tcp.ListenerChor.Chorex, :accepterpool

  def spawn_handler(_socket) do
	# startup instance of the handler choreography
  end
end
