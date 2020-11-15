defmodule Comm.Helpers.PG2 do
  @moduledoc "A collection of helpers for PG2 usage."

  @doc """
  Joins the specified `pid` to the specified `group`. If the group doesn't
  already exist, it will be created and then the process will join it.
  """
  def join_or_create(pid, group) do
    case :pg2.join(group, pid) do
      {:error, {:no_such_group, name}} ->
        require Logger
        :ok = :pg2.create(name)
        :pg2.join(group, pid)

      :ok ->
        :ok
    end
  end

  def leave(pid, group) do
    :pg2.leave(group, pid)
  end

  def get_members(group) do
    case :pg2.get_members(group) do
      [_ | _] = members ->
        members

      {:error, {:no_such_group, _name}} ->
        []
    end
  end

  def create(group) do
    require Logger
    :pg2.create(group)
  end
end
