defmodule Tcp.ClientImpl do
  use Tcp.HandlerChor.Chorex, :tcpclient

  def read(sock) do
    :gen_tcp.recv(sock, 100)
  end

  def send_over_socket(sock, msg) do
    IO.inspect(msg, label: "[client] msg")
    :gen_tcp.send(sock, msg)
  end
end
