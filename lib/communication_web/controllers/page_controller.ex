defmodule CommunicationWeb.PageController do
  use CommunicationWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
