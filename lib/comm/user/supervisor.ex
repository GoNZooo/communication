defmodule Comm.User.Supervisor do
  use DynamicSupervisor

  def start_link([]) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(user) do
    DynamicSupervisor.start_child(__MODULE__, %{
      :id => Comm.User,
      :start => {Comm.User, :start_link, [user]},
      :restart => :temporary,
      :shutdown => :brutal_kill,
      :type => :worker
    })
  end

  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
