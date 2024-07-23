defmodule ChorexExamples do
  @moduledoc """
  Documentation for `ChorexExamples`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ChorexExamples.hello()
      :world

  """
  def hello do
    :world
  end

  def start_server() do
    Chorex.start(
      Tcp.ListenerChor.Chorex,
      %{Listener => Tcp.ListenerImpl, AccepterPool => Tcp.AccepterPoolImpl},
      [%{port: 4242, user_options: []}]
    )
  end
end
