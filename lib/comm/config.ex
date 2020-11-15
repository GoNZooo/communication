defmodule Comm.Config do
  alias Comm.ActionHandler.Slack.Torrent

  def started_handlers(config) do
    handlers = []

    handlers =
      handlers ++
        if config["slack"]["torrent"]["enabled"] do
          [{Torrent, ["torrents", config["slack"]["torrent"]["url"]]}]
        else
          []
        end

    handlers
  end

  def initial_rooms(%{"rooms" => %{"public" => public, "private" => private}}) do
    create_args(public, :public) ++ create_args(private, :private)
  end

  def read() do
    priv_dir = :code.priv_dir(:communication)

    case YamlElixir.read_all_from_file(Path.join(priv_dir, "config.yaml")) do
      {:ok, [cfg]} ->
        cfg

      {:error, %{message: error_message}} ->
        raise("Unable to read config file: " <> error_message)
    end
  end

  defp create_args(nil, _) do
    []
  end

  defp create_args(rooms, :public) do
    Enum.map(rooms, &[&1, false])
  end

  defp create_args(rooms, :private) do
    Enum.map(rooms, &[&1, true])
  end
end
