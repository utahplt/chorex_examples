defmodule Tcp.ClientImpl do
  use Tcp.HandlerChor.Chorex, :tcpclient

  def send_over_socket(_sock, _msg) do
  end
end
