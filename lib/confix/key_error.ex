defmodule Confix.KeyError do
  @moduledoc """
  Raised when required configuration is missing.
  """

  defexception [:key_or_keys, :module]

  def message(%__MODULE__{key_or_keys: key_or_keys, module: nil}) do
    "#{inspect key_or_keys} not set"
  end
  def message(%__MODULE__{key_or_keys: key_or_keys, module: module}) when is_atom(module) do
    "#{inspect key_or_keys} not set for #{inspect module}"
  end
end
