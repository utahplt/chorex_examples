defmodule Tcp.HandlerImpl do
  use Tcp.HandlerChor.Chorex, :handler

  def run({:error, reason}) do
    IO.inspect(reason, label: "[handler] error reason")
    {:halt, ""}
  end

  def run({:ok, "stop\n"}) do
    {:halt, "Thank you for your time. Goodbye now!\n"}
  end

  def run({:ok, msg}) do
    IO.inspect(msg, label: "[handler] msg")
    len = String.length(msg)
    {:continue, "thank you for your message; #{len} bytes\n"}
  end

  def continue?({:continue, _resp}), do: true
  def continue?({:halt, _resp}), do: false
  def continue?(:closed), do: false

  def fmt_reply({_status, resp}), do: resp

  def ack_shutdown() do
	IO.inspect("down", label: "[handler] shutting down")
    nil
  end
end
