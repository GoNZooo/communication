defmodule Comm.ActionHandler do
  def start_link(module, args) do
    :erlang.apply(module, :start_link, args)
  end

  def event(handler, event) when is_binary(event) do
    event(handler, Poison.decode!(event))
  end

  def event(handler, event = %{}) do
    send(handler, event)
  end
end
