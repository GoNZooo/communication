defmodule Comm.User.State do
  alias Comm.User

  @enforce_keys [:user]
  defstruct [:user, action_handlers: []]

  @type t :: %__MODULE__{user: User.user(), action_handlers: [any]}
end
