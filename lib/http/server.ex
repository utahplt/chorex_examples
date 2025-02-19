defmodule Http.Server do
  use Http.Chor.Chorex, :server

  @impl true
  def handle(_headers, _body) do
  end

  @impl true
  def accept?(_headers) do
    false
  end

  @impl true
  def accept_length(_headers) do
    42
  end
end
