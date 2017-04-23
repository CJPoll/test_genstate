defmodule TestGenstate do
  use Application

  def start(_, _) do
    import Supervisor.Spec

    children = [
      worker(TestGenState.LockingDoor, [Door])
    ]

    opts = [strategy: :one_for_one]

    Supervisor.start_link(children, opts)
  end
end
