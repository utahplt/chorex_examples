defmodule Tcp.HandlerChor do
  import Chorex

  defchor [Handler, TcpClient] do
    def run(TcpClient.(sock)) do
      loop(Handler.(%{byte_count: 0}), TcpClient.(sock))
    end

    def loop(Handler.(state), TcpClient.(sock)) do
      TcpClient.read(sock) ~> Handler.(msg)

      with Handler.({resp, new_state}) <- Handler.run(msg, state) do
        if Handler.continue?(resp, new_state) do
          Handler[L] ~> TcpClient
          Handler.fmt_reply(resp) ~> TcpClient.(resp)
          TcpClient.send_over_socket(sock, resp)
          loop(Handler.(new_state), TcpClient.(sock))
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
