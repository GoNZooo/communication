defmodule Comm.Room.Supervisor do
  use DynamicSupervisor

  def start_link([]) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(name, private?) do
    DynamicSupervisor.start_child(__MODULE__, %{
      :id => Comm.Room,
      :start => {Comm.Room, :start_link, [name, private?]},
      :restart => :temporary,
      :shutdown => :brutal_kill,
      :type => :worker
    })
  end

  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
