defmodule Tcp.ListenerChor do
  import Chorex

  defchor [Listener, AccepterPool] do
    def run(Listener.(config)) do
      Listener.get_listener_socket(config) ~> AccepterPool.({:ok, socket})
      loop(AccepterPool.(socket))
    end

    def loop(AccepterPool.(listen_socket)) do
      AccepterPool.accept_and_handle_connection(listen_socket)
      loop(AccepterPool.(listen_socket))
    end
  end

  # # Tcp.ListenerChor.Chorex
  # defchor [Listener, AccepterPool] do
  #   alias Tcp.HandlerChor

  #   def run(Listener.(config)) do
  #     Listener.await_connection(config) ~> AccepterPool.({:ok, socket})

  #     sub_chor(HandlerChor.Chorex,
  #       supervisor: AcceptorPool,
  #       args: [AccepterPool.(socket)])

  #     run(Listener.(config))
  #   end
  # end
end
