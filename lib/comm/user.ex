defmodule Comm.User do
  use GenServer

  require Logger

  alias Comm.{User.State, Helpers.PG2}

  @user_group :users

  @type start_link_ret :: {:ok, pid} | {:error, {:already_started, pid}}
  @type t :: binary

  def new(user) do
    Comm.User.Supervisor.start_child(user)
  end

  def register_user(handler, user) do
    PG2.join_or_create(handler, @user_group)
    :global.register_name(name(user), handler)
  end

  @spec start_link(user :: t) :: start_link_ret
  def start_link(user) do
    GenServer.start_link(__MODULE__, [user], name: {:global, name(user)})
  end

  @spec init(args :: [any]) :: {:ok, State.t()}
  def init([user]) do
    PG2.join_or_create(self(), @user_group)
    {:ok, %State{user: user}}
  end

  @spec name(user :: t) :: {atom, t}
  def name(user) do
    {__MODULE__, user}
  end

  def rename(user, new_name) do
    user_pid = :global.whereis_name(name(user))
    :global.unregister_name(name(user))
    :global.register_name(name(new_name), user_pid)
  end

  def handle_info(
        %{"type" => "message", "room" => room, "data" => %{"sender" => sender, "message" => msg}},
        %State{user: user} = state
      ) do
    Logger.debug("#{user} received msg '#{msg}' from #{sender} in #{room}")
    {:noreply, state}
  end

  def handle_info(%{} = event, state) do
    Logger.debug("#{state.user} received event: #{inspect(event)}")
    {:noreply, state}
  end
end
