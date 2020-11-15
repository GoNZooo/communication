defmodule Comm.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Comm.Config

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    config = Comm.Config.read()

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Comm.Worker.start_link(arg1, arg2, arg3)
      # worker(Comm.Worker, [arg1, arg2, arg3]),
      {Comm.Room.Supervisor, []},
      {Comm.Room.Manager, [Config.initial_rooms(config)]},
      {Comm.ActionHandler.Supervisor, []},
      {Comm.ActionHandler.Manager, [Config.started_handlers(config)]},
      {Comm.User.Supervisor, []}
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Comm.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
