defmodule Tcp.HandlerImpl do
  use Tcp.HandlerChor.Chorex, :handler

  def run({:error, reason}, state) do
    IO.inspect(reason, label: "[handler] error reason")
    {{:halt, ""}, state}
  end

  def run({:ok, "stop\n"}, state) do
    {{:halt, "Thank you for your time. Goodbye now!\n"}, state}
  end

  def run({:ok, msg}, state) do
    IO.inspect(msg, label: "[handler] msg")
    len = String.length(msg)
    c = Map.get(state, :byte_count, 0)
    {{:continue, "thank you for your message; #{len} bytes, #{len + c} total\n"},
     %{byte_count: c + len}}
  end

  def continue?({:continue, _resp}, _state), do: true
  def continue?({:halt, _resp}, _state), do: false
  def continue?(:closed, _state), do: false

  def fmt_reply({_status, resp}), do: resp

  def ack_shutdown() do
	IO.inspect("down", label: "[handler] shutting down")
    nil
  end
end
