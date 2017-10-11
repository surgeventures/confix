defmodule Confix.Patch do
  @moduledoc """
  Patches any Mix config with `Confix`.
  """

  alias Mix.Config

  @doc """
  Patches current Mix config with `Confix` using preconfigured schema.

  ## Examples

  In order to execute this extension on application start, set an appropriate config key:

      config :confix, patch: [
        sentry: [
          environment: {:system, "SENTRY_ENVIRONEMNT"}
        ]
      ]

  """
  def init do
    require Logger

    case Application.fetch_env(:confix, :patch) do
      {:ok, schema} ->
        new_config = apply(schema)
        Logger.info fn ->
          "Patching config: #{inspect new_config}"
        end

      :error ->
        nil
    end
  end

  @doc """
  Patches current Mix config with `Confix` using given schema.

  ## Examples

      Confix.Patch.apply(sentry: [
        environment: {:system, "SENTRY_ENVIRONEMNT"}
      ])

  """
  def apply(schema) do
    new_config = resolve(schema)
    Config.persist(new_config)
    new_config
  end

  defp resolve(tuple = {:system, _}), do: Confix.parse(tuple)
  defp resolve(tuple = {:system, _, _}), do: Confix.parse(tuple)
  defp resolve(list) when is_list(list) do
    Enum.map(list, &resolve/1)
  end
  defp resolve({key, value}), do: {key, resolve(value)}
  defp resolve(value), do: value
end
