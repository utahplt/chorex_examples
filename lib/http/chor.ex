defmodule Http.Chor do
  import Chorex

  defchor [Client, Server] do
    def run(_) do
      Client.get_headers() ~> Server.(headers)

      if Server.accept?(headers) do
        Server[L] ~> Client
        Server.accept_length(headers) ~> Client.(body_length)
        Client.get_body(body_length) ~> Server.(body)
        Server.handle(headers, body) ~> Client.(response)
        Client.finish_request(response)
      else
        Server[R] ~> Client
        Client.finish_request(nil)
      end
    end
  end
end
