defmodule Confix do
  @moduledoc """
  Reads and parses the application's Mix config.

  ## Usage

  In order to get values, you may first add dynamic configuration to `config/prod.exs`:

      config :confix,
        base_app: :my_project # defaults to Mix app, so it's usually not needed

      config :my_project,
        feature_x_enabled: {:system, "FEATURE_X_ENABLED", type: :boolean, default: false}

      config :my_project, MyProject.Web.Endpoint,
        pubsub: [url: {:system, "REDIS_URL"}]

  You may get these values in your own code:

      iex> Confix.get(:feature_x_enabled)
      false
      iex> System.put_env("FEATURE_X_ENABLED", "1")
      :ok
      iex> Confix.get(:feature_x_enabled)
      true
      iex> System.put_env("REDIS_URL", "redis://localhost:6379")
      :ok
      iex> Confix.get_in(MyProject.Web.Endpoint, [:pubsub, :url])
      "redis://localhost:6379"

  You may also want to parse arbitrary configuration that doesn't come from Mix:

      iex> System.put_env("ADAPTER_URL", "http://example.com")
      :ok
      iex> Confix.parse({:system, "ADAPTER_URL"})
      "http://example.com"
      iex> Confix.deep_parse(adapter: [url: {:system, "ADAPTER_URL"}])
      [adapter: [url: "http://example.com"]]

  Sometimes however the place where you'd like system tuples to be read lies outside your own code
  and in 3rd party applications that don't natively support them. That could be (and actually is)
  the case of `MyProject.Web.Endpoint` on examples above - the Redis adapter for Phoenix PubSub
  doesn't properly parse the system tuples. In such cases, 3rd party config can be easily patched
  with `Confix.Application`.

  ## Usage in modules

  You may also `use Confix` in your own modules in order to have quick means for getting config
  associated with that particular module:

      defmodule MyProject.MyHTTPClient do
        use Confix

        def call do
          url = config!(:url)

          # ...
        end
      end

  ## Syntax

  System tuples may have the following syntax:

      {:system, "ENV_VAR"}
      {:system, "ENV_VAR", default: "xyz"}
      {:system, "ENV_VAR", type: :integer}
      {:system, "ENV_VAR", type: :boolean, default: true}
      {:system, ["ENV_VAR_1", "ENV_VAR_2"]}

  """

  alias __MODULE__.KeyError

  defmacro __using__(_) do
    quote do
      @doc """
      Gets config for this module using `Confix` or return nil if missing.
      """
      def config(key_or_keys)
      def config(key) when not(is_list(key)), do: config([key])
      def config(keys) do
        Confix.get_in([__MODULE__] ++ keys)
      end

      @doc """
      Gets config for this module using `Confix` or raises `Confix.KeyError` if missing.
      """
      def config!(key_or_keys) do
        config(key_or_keys) || raise(KeyError, key_or_keys: key_or_keys, module: __MODULE__)
      end
    end
  end

  @doc """
  Gets the parsed config value for specified key.

  ## Options

  - `:app` - specifies the app to get config for, default: `:base_app` config or Mix app name
  - `:deep` - deep parses the retrieved value, default: `false`

  ## Examples

      iex> Confix.get(:feature_x_enabled)
      false
      iex> System.put_env("FEATURE_X_ENABLED", "1")
      :ok
      iex> Confix.get(:feature_x_enabled)
      true

  """
  def get(key, opts \\ []) do
    opts
    |> get_app_name
    |> Application.get_env(key)
    |> get_parsed_value(opts)
  end

  @doc """
  Same as `get/2` but raises `Confix.KeyError` if config is missing.
  """
  def get!(key, opts \\ []) do
    get(key, opts) || raise(KeyError, key_or_keys: key)
  end

  defp get_app_name(opts) do
    case Keyword.fetch(opts, :app) do
      {:ok, app_name} ->
        app_name
      :error ->
        Application.get_env(:confix, :base_app, Mix.Project.config[:app])
    end
  end

  defp get_parsed_value(value, opts) do
    if Keyword.get(opts, :deep, false) do
      parse_deep(value)
    else
      parse(value)
    end
  end

  @doc """
  Gets the parsed config value for specified list of nested keys.

  ## Options

  - `:app` - specifies the app to get config for, default: `:base_app` config or Mix app name
  - `:deep` - deep parses the retrieved value, default: `false`

  ## Examples

      iex> System.put_env("REDIS_URL", "redis://localhost:6379")
      :ok
      iex> Confix.get_in(MyProject.Web.Endpoint, [:pubsub, :url])
      "redis://localhost:6379"

  """
  def get_in(keys, opts \\ [])
  def get_in([root_key | deep_keys], opts) do
    opts
    |> get_app_name
    |> Application.get_env(root_key)
    |> Kernel.get_in(deep_keys)
    |> get_parsed_value(opts)
  end

  @doc """
  Same as `get_in/2` but raises `Confix.KeyError` if config is missing.
  """
  def get_in!(keys, opts \\ []) do
    __MODULE__.get_in(keys, opts) || raise(KeyError, key_or_keys: keys)
  end

  @doc """
  Parses a config value which may or may not be a system tuple.

  ## Examples

      iex> System.put_env("ADAPTER_URL", "http://example.com")
      :ok
      iex> Confix.parse({:system, "ADAPTER_URL"})
      "http://example.com"

  """
  def parse({:system, env}), do: parse({:system, env, []})
  def parse({:system, env, opts}) do
    type = Keyword.get(opts, :type)
    default = Keyword.get(opts, :default)

    env
    |> get_env
    |> apply_type(type)
    |> apply_default(default)
  end
  def parse(value), do: value

  defp get_env(env) when is_binary(env), do: System.get_env(env)
  defp get_env(envs) when is_list(envs) do
    Enum.find_value(envs, &get_env/1)
  end

  defp apply_type(value, nil), do: value
  defp apply_type("1", :boolean), do: true
  defp apply_type("0", :boolean), do: false
  defp apply_type(nil, :boolean), do: nil
  defp apply_type(value, :integer) when is_binary(value), do: String.to_integer(value)
  defp apply_type(nil, :integer), do: nil

  defp apply_default(value, nil), do: value
  defp apply_default(nil, default), do: default
  defp apply_default(value, _default), do: value

  @doc """
  Parses a nested config structure which may or may not contain system tuples.

  ## Examples

      iex> System.put_env("ADAPTER_URL", "http://example.com")
      :ok
      iex> Confix.deep_parse(adapter: [url: {:system, "ADAPTER_URL"}])
      [adapter: [url: "http://example.com"]]

  """
  def parse_deep(list) when is_list(list), do: Enum.map(list, &parse_deep/1)
  def parse_deep(tuple = {:system, _}), do: parse(tuple)
  def parse_deep(tuple = {:system, _, _}), do: parse(tuple)
  def parse_deep({key, value}), do: {key, parse_deep(value)}
  def parse_deep(value), do: parse(value)
end
