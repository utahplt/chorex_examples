defmodule Tcp.ListenerChor do
  import Chorex

  defchor [Listener, AccepterPool] do
    def loop(Listener.(_x)) do # FIXME: functions without an argument; or is it that all branches loop?
      Listener.await_connection() ~> AccepterPool.(socket)
      AccepterPool.spawn_handler(socket)
      loop(Listener.(nil))
    end

    loop(Listener.(nil))
  end
end
