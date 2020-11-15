defmodule Comm.Room do
  @moduledoc """
  Describes a chat room and its participants. The rooms are registered globally
  and they join a `pg2` group that groups all rooms.
  """
  use GenServer

  require Logger

  alias Comm.{User, ActionHandler, Helpers.PG2, Room.State}

  @room_group :rooms
  @handlers_tag :handlers

  @type start_link_ret :: {:ok, pid} | {:error, {:already_started, pid}}
  @type t :: binary

  @spec start_link(room :: t, private? :: boolean) :: start_link_ret
  def start_link(room, private? \\ false) do
    GenServer.start_link(__MODULE__, [room, private?], name: {:global, name(room)})
  end

  @spec join(user :: User.t(), room :: t) :: :ok
  @doc "Joins the specified `user` to a `room`."
  def join(user, room) do
    user_pid = :global.whereis_name({Comm.User, user})
    add_handler(user_pid, room)
    notify_handlers(get_handlers(room), %{type: :join, data: %{joiner: user}})
  end

  @spec add_handler(handler :: pid, room :: t) :: :ok
  @doc """
  Adds a handler (web hook or the like) to the room. The handler will receive
  an event whenever the room receives a message/event. This will then be
  processed as needed by each handler that cares about the message, and will
  automatically be ignored if it's not interesting to the handler.
  """
  def add_handler(handler, room) do
    PG2.join_or_create(handler, handlers_group(room))
  end

  @spec leave(user :: User.t(), room :: t) :: :ok
  @doc "Leaves the specified `user` from a `room`."
  def leave(user, room) do
    user_pid = :global.whereis_name({Comm.User, user})
    remove_handler(user_pid, room)
    notify_handlers(get_handlers(room), %{type: :leave, data: %{leaver: user}})
  end

  @spec remove_handler(handler :: pid, room :: t) :: :ok
  @doc "Disconnects a handler from a room."
  def remove_handler(handler, room) do
    PG2.leave(handler, handlers_group(room))
  end

  @spec message(room :: t, sender :: User.t(), message :: term) :: :ok
  @doc """
  Sends `message` to all participants of a room. This is implemented as a normal
  event and consequently the participants registered to a room will just be
  action handlers.
  """
  def message(room, sender, message) do
    event = %{
      "type" => "message",
      "room" => room,
      "data" => %{"sender" => sender, "message" => message}
    }

    notify_handlers(get_handlers(room), event)
  end

  def event(room, event) do
    notify_handlers(get_handlers(room), event)
  end

  def notify_handlers(handlers, event) do
    Enum.each(handlers, &ActionHandler.event(&1, event))
  end

  @spec get_rooms :: [pid]
  @doc "Retrieves a list of pids representing all registered rooms."
  def get_rooms do
    PG2.get_members(@room_group)
  end

  def get_handlers(room) do
    PG2.get_members(handlers_group(room))
  end

  @spec init(args :: [any]) :: {:ok, State.t()}
  def init([room, private?]) do
    PG2.join_or_create(self(), @room_group)
    PG2.create(handlers_group(room))

    {:ok, %State{room: room, private?: private?}}
  end

  @spec name(room :: t) :: {atom, t}
  def name(room) do
    {__MODULE__, room}
  end

  @spec handlers_group(room :: t) :: {atom, t}
  def handlers_group(room) do
    {@handlers_tag, room}
  end
end
