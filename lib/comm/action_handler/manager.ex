defmodule Comm.ActionHandler.Manager do
  use GenServer

  require Logger

  alias Comm.ActionHandler.Supervisor, as: HandlerSupervisor

  def start_link([initial_handlers]) do
    GenServer.start_link(__MODULE__, [initial_handlers], name: __MODULE__)
  end

  def init([initial_handlers]) do
    state =
      initial_handlers
      |> start_handlers()
      |> Enum.map(&monitor/1)

    {:ok, state}
  end

  defp start_handlers(handlers) do
    Enum.map(handlers, fn {mod, args} ->
      {mod, args, HandlerSupervisor.start_child(mod, args)}
    end)
  end

  defp monitor({mod, args, {:ok, pid}}) do
    {mod, args, Process.monitor(pid)}
  end

  defp monitor({mod, args, error}) do
    Logger.warn("Couldn't monitor #{inspect(mod)} (#{inspect(args)}), #{inspect(error)}")
    {mod, args, error}
  end
end
