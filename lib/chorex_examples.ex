defmodule ChorexExamples do
  def start_server() do
    Chorex.start(
      Tcp.ListenerChor.Chorex,
      %{Listener => Tcp.ListenerImpl, AccepterPool => Tcp.AccepterPoolImpl},
      [%{port: 4242, user_options: []}]
    )
  end
end
