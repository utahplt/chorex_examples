defmodule Tcp.HandlerImpl do
  use Tcp.HandlerChor.Chorex, :handler

  def run() do
  end

  def continue?({:continue, _resp}), do: true
  def continue?({:halt, _resp}), do: false

  def fmt_reply({_status, resp}), do: resp

end
