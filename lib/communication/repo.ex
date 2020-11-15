defmodule Communication.Repo do
  use Ecto.Repo,
    otp_app: :communication,
    adapter: Ecto.Adapters.Postgres
end
