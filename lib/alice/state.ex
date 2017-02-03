defmodule Alice.State do
  @moduledoc "Used to store and manipulate the bot state"
  use GenServer

  # Public API

  def start_link, do: start_link(Application.get_env(:alice, :state_backend))
  def start_link(backend) do
    GenServer.start_link(__MODULE__, backend, name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def put_state(state) do
    GenServer.cast(__MODULE__, {:put_state, state})
  end

  # Callbacks

  def init(backend) do
    case backend do
      :redis -> {:ok, Alice.StateBackends.Redis.get_state}
      _other -> {:ok, %{}}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:put_state, new_state}, _old_state) do
    {:noreply, new_state}
  end
end
