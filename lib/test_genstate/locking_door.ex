defmodule TestGenState.LockingDoor do
  @behaviour :gen_statem

  defmodule Data do
    defstruct [times_locked: 0]
  end

  ## ---------------------------------------------------------------------------
  ## Public Functions
  ## ---------------------------------------------------------------------------
  def start_link do
    :gen_statem.start_link(__MODULE__, [], [])
  end

  def start_link(name) do
    IO.inspect("Starting with name: #{name}")
    :gen_statem.start_link({:local, name}, __MODULE__, [], [])
  end

  def open(pid) do
    :gen_statem.cast(pid, :open)
  end

  def lock(pid) do
    :gen_statem.cast(pid, :lock)
  end

  ## ---------------------------------------------------------------------------
  ## Callback Functions
  ## ---------------------------------------------------------------------------

  def init(_) do
    # --------------------------------------------------------------------------
    # Called when the FSM is initialized (after calling start_link)
    # --------------------------------------------------------------------------
    {:ok, :open, %Data{}} |> IO.inspect
  end

  def callback_mode do
    # --------------------------------------------------------------------------
    # Configures certain things about the process' behavior (see docs)
    # --------------------------------------------------------------------------
    [:state_functions, :state_enter]
  end

  def code_change(_old_version, state, data, _extra) do
    {:ok, state, data}
  end

  def terminate(_reason, _state, _data), do: :ok

  ## ---------------------------------------------------------------------------
  ## Event Handlers
  ## ---------------------------------------------------------------------------
  def open(_, :lock, data) do
    {:next_state, :locked, data}
  end

  def open(_, _, data) do
    {:next_state, :open, data}
  end

  def locked(:enter, :open, %Data{} = data) do
    # --------------------------------------------------------------------------
    # Called when the state "locked" is entered from another state.
    # --------------------------------------------------------------------------
    IO.inspect("Entering Locked from Open")
    data = %Data{data | times_locked: data.times_locked + 1}
    IO.inspect(data)
    {:next_state, :locked, data}
  end

  def locked(_event_type, :open, data) do
    {:next_state, :open, data}
  end

  def locked(_event_type, :lock, data) do
    {:next_state, :locked, data}
  end
end
