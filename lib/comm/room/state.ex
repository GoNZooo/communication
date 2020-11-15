defmodule Comm.Room.State do
  @moduledoc "Holds the state for a room."

  alias Comm.Room
  alias Comm.User

  @enforce_keys [:room, :private?]
  defstruct [:room, private?: false, messages: []]

  @type message :: {:msg, room :: Room.room(), sender :: User.user(), msg :: binary}

  @type t :: %__MODULE__{room: Room.room(), private?: boolean, messages: [message]}
end
