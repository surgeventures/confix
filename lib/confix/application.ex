defmodule Confix.Application do
  @moduledoc """
  Patches the specified application's Mix configs upon project startup.

  ## Usage

  Set the following in your `config/prod.exs`:

      config :confix, :patch,
        my_project: MyProject.Web.Endpoint, # patches specific key in specific application
        project_2: [], # patches all keys in specific application
        project_3: [:adapter, :url] # patches only given nested key in specific application

  That's it. The configuration for specific apps and keys will be parsed using `Confix.parse_deep/1`
  and persisted in the Mix config. So all system tuples will be replaced with actual environment
  variable values, with optional casting and defaults as specified in the `Confix` module docs.

  """

  use Application
  use GenServer
  require Logger

  @doc false
  def start(_type, _args) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    case Application.fetch_env(:confix, :patch) do
      {:ok, keys_list} ->
        Enum.each(keys_list, fn keys ->
          keys
          |> normalize
          |> apply
        end)

      :error ->
        nil
    end

    {:ok, nil, :hibernate}
  end

  defp normalize([app]), do: [app]
  defp normalize(keys) when is_list(keys), do: keys
  defp normalize({app, []}), do: [app]
  defp normalize({app, keys}) when is_list(keys), do: [app | keys]
  defp normalize({app, key}), do: [app, key]
  defp normalize(app), do: [app]

  defp apply([app]) do
    keys =
      app
      |> Application.get_all_env
      |> Keyword.keys

    Enum.each(keys, &apply([app, &1]))
  end
  defp apply([app, key]) do
    new =
      app
      |> Application.get_env(key, [])
      |> Confix.parse_deep

    Logger.info fn ->
      "Patching config for #{inspect app}, #{inspect key}"
    end

    Application.put_env(app, key, new, persistent: true)
  end
  defp apply([app, root_key | deep_keys]) do
    new_root =
      app
      |> Application.get_env(root_key, [])
      |> update_in(deep_keys, &Confix.parse_deep/1)

    Application.put_env(app, root_key, new_root, persistent: true)
  end
end
