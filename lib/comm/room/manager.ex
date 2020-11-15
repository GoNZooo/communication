defmodule Comm.Room.Manager do
  use GenServer

  require Logger

  alias Comm.Room.Supervisor, as: RoomSupervisor

  def start_link([initial_rooms]) do
    GenServer.start_link(__MODULE__, [initial_rooms], name: __MODULE__)
  end

  def init([initial_rooms]) do
    state =
      initial_rooms
      |> Enum.map(fn [name, private?] ->
        {name, private?, RoomSupervisor.start_child(name, private?)}
      end)
      |> Enum.map(&monitor/1)

    {:ok, state}
  end

  defp monitor({name, private?, {:ok, pid}}) do
    {name, private?, Process.monitor(pid)}
  end

  defp monitor({name, private?, error}) do
    Logger.warn("Couldn't monitor room '#{inspect(name)}', #{inspect(error)}.")

    {{name, private?}, error}
  end
end
