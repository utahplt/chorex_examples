defmodule Tcp.ListenerImpl do
  use Tcp.ListenerChor.Chorex, :listener

  def await_connection() do
    42
  end
end
