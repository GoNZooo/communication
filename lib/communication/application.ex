defmodule Communication.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Comm.Config

  def start(_type, _args) do
    config = Comm.Config.read()

    children = [
      {Comm.Room.Supervisor, []},
      {Comm.Room.Manager, [Config.initial_rooms(config)]},
      {Comm.ActionHandler.Supervisor, []},
      {Comm.ActionHandler.Manager, [Config.started_handlers(config)]},
      {Comm.User.Supervisor, []},

      # Start the Ecto repository
      Communication.Repo,
      # Start the Telemetry supervisor
      CommunicationWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Communication.PubSub},
      # Start the Endpoint (http/https)
      CommunicationWeb.Endpoint
      # Start a worker by calling: Communication.Worker.start_link(arg)
      # {Communication.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Communication.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CommunicationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
