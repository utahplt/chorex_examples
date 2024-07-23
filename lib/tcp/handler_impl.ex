defmodule Tcp.HandlerImpl do
  use Tcp.HandlerChor.Chorex, :handler

  def run(msg) do
    IO.inspect(msg, label: "[handler] msg")
    {:halt, "you did it!"}
  end

  def continue?({:continue, _resp}), do: true
  def continue?({:halt, _resp}), do: false

  def fmt_reply({_status, resp}), do: resp
end
