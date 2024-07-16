defmodule Tcp.ListenerChor do
  import Chorex

  defchor [Listener, AccepterPool] do
    def loop(Listener.(_x)) do
      Listener.await_connection() ~> AccepterPool.(socket)
      AccepterPool.spawn_handler(socket)
      loop(Listener.(nil))
    end

    loop(Listener.(nil))
  end
end
