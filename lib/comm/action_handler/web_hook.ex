defmodule Comm.ActionHandler.WebHook do
  def post!(url, data) do
    HTTPoison.post!(url, Poison.encode!(data))
  end
end
