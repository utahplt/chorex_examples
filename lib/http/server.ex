defmodule Http.Server do
  use Http.Chor.Chorex, :server

  def handle(_headers, _body) do
  end

  def accept?(_headers) do
	false
  end

  def accept_length(_headers) do
	42
  end
end
