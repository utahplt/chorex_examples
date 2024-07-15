defmodule Tcp.HandlerChor do
  import Chorex

  defchor [Handler, TcpClient] do
    def loop(Handler.(_x)) do
      with Handler.(resp) <- Handler.run() do
        if Handler.continue?(resp) do
          Handler[L] ~> TcpClient
          Handler.fmt_reply(resp) ~> TcpClient.(resp)
          TcpClient.send(resp)
          loop(Handler.(nil))
        else
          Handler[R] ~> TcpClient
          Handler.fmt_reply(resp) ~> TcpClient.(resp)
          TcpClient.send(resp)
        end
      end
    end

    loop(Handler.(nil))
  end
end
