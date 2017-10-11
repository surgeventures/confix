defmodule Confix.Application do
  @moduledoc """
  Main Confix OTP application that calls patches configured for running and hibernates itself.
  """

  use Application
  use GenServer
  require Logger
  alias Confix.Patch

  @doc false
  def start(_type, _args) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    Patch.init()

    {:ok, nil, :hibernate}
  end
end
