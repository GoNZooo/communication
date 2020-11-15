# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :communication,
  ecto_repos: [Communication.Repo]

# Configures the endpoint
config :communication, CommunicationWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZBq4pjV7Ut1utwnPnIr37Ranz7iuwNoTcNa8w+S1pLzB2hAa0jR/BFtDrb4qMnU3",
  render_errors: [view: CommunicationWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Communication.PubSub,
  live_view: [signing_salt: "zu7JjKZQ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
