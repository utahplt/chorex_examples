defmodule TcpServer do
  use Application

  @impl true
  def start(_type, _args) do
	ChorexExamples.start_server()
    {:ok, self()}
  end
end
