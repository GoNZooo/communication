defmodule Comm.ActionHandler.Slack.Torrent do
  use GenServer

  require Logger

  alias Comm.{Room, ActionHandler.WebHook.State, ActionHandler.WebHook}

  @type start_link_ret :: {:ok, pid} | {:error, {:already_started, pid}}

  @spec start_link(room :: Room.t(), url :: binary) :: start_link_ret
  def start_link(room, url) do
    GenServer.start_link(__MODULE__, [room, url])
  end

  def init([room, url]) do
    send(self(), {:join_after_init, room})

    {:ok, %State{room: room, url: url}}
  end

  def handle_info(
        %{"type" => "torrent_downloaded", "data" => %{"title" => title}},
        s
      ) do
    WebHook.post!(s.url, %{text: "Downloaded: #{title}"})

    {:noreply, s}
  end

  def handle_info(
        %{"type" => "message", "data" => %{"sender" => sender, "message" => msg}},
        %State{} = s
      ) do
    WebHook.post!(s.url, %{text: "#{sender} in #{s.room}: #{msg}"})

    {:noreply, s}
  end

  def handle_info(%{"type" => "ping"}, s) do
    WebHook.post!(s.url, %{text: "Received ping!"})

    {:noreply, s}
  end

  def handle_info(%{} = event, %State{} = s) do
    Logger.debug("Event: #{inspect(event)} in #{s.room} | #{s.url}")

    {:noreply, s}
  end

  def handle_info({:join_after_init, room}, s) do
    Room.add_handler(self(), room)

    {:noreply, s}
  end
end
