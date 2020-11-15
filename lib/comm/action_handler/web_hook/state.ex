defmodule Comm.ActionHandler.WebHook.State do
  alias Comm.Room

  @enforce_keys [:room, :url]
  defstruct [:room, :url]

  @type t :: %__MODULE__{room: Room.t(), url: binary}
end
