defmodule Tcp.HandlerChor do
  import Chorex

  defchor [Handler, TcpClient] do
    def loop(TcpClient.(sock)) do
      with Handler.(resp) <- Handler.run() do
        if Handler.continue?(resp) do
          Handler[L] ~> TcpClient
          Handler.fmt_reply(resp) ~> TcpClient.(resp)
          TcpClient.send_over_socket(sock, resp)
          loop(TcpClient.(sock))
        else
          Handler[R] ~> TcpClient
          Handler.fmt_reply(resp) ~> TcpClient.(resp)
          TcpClient.send_over_socket(sock, resp)
        end
      end
    end

    def init(TcpClient.(sock)) do
      loop(TcpClient.(sock))
    end
  end

  # quote do
  #   defchor [Handler, TcpClient] do
  #     def loop(TcpClient.(sock)) do
  #       with Handler.(resp) <- Handler.run() do
  #         if Handler.continue?(resp) do
  #           Handler[L] ~> TcpClient
  #           Handler.fmt_reply(resp) ~> TcpClient.(resp)
  #           TcpClient.send_over_socket(sock, resp)
  #           loop(TcpClient.(sock))
  #         else
  #           Handler[R] ~> TcpClient
  #           Handler.fmt_reply(resp) ~> TcpClient.(resp)
  #           TcpClient.send_over_socket(sock, resp)
  #         end
  #       end
  #     end

  #     def init(TcpClient.(sock)) do
  #       loop(TcpClient.(sock))
  #     end
  #   end
  # end
  # |> Macro.expand_once(__ENV__)
  # |> Macro.to_string()
  # |> IO.puts()
end
