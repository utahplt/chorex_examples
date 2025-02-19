defmodule Tcp.ClientImpl do
  use Tcp.HandlerChor.Chorex, :tcpclient

  @impl true
  def read(sock) do
    :gen_tcp.recv(sock, 0)      # 0 = all available bytes
  end

  @impl true
  def send_over_socket(sock, msg) do
    IO.inspect(msg, label: "[client] msg")
    :gen_tcp.send(sock, msg)
  end

  @impl true
  def shutdown(sock) do
    :gen_tcp.close(sock)
  end
end
