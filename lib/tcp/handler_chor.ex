defmodule Tcp.HandlerChor do
  import Chorex

  defchor [Handler, TcpClient] do
    def run(TcpClient.(sock)) do
      TcpClient.read(sock) ~> Handler.(msg)
      with Handler.(resp) <- Handler.run(msg) do
        if Handler.continue?(resp) do
          Handler[L] ~> TcpClient
          Handler.fmt_reply(resp) ~> TcpClient.(resp)
          TcpClient.send_over_socket(sock, resp)
          run(TcpClient.(sock))
        else
          Handler[R] ~> TcpClient
          Handler.fmt_reply(resp) ~> TcpClient.(resp)
          TcpClient.send_over_socket(sock, resp)
          TcpClient.shutdown(sock)
          Handler.ack_shutdown()
        end
      end
    end
  end
end
