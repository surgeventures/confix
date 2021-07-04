# Confix

[![CI](https://github.com/surgeventures/confix/actions/workflows/ci.yml/badge.svg)](https://github.com/surgeventures/confix/actions/workflows/ci.yml)
[![Module Version](https://img.shields.io/hexpm/v/confix.svg)](https://hex.pm/packages/confix)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/confix/)
[![Total Download](https://img.shields.io/hexpm/dt/confix.svg)](https://hex.pm/packages/confix)
[![License](https://img.shields.io/hexpm/l/confix.svg)](https://github.com/surgeventures/confix/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/surgeventures/confix.svg)](https://github.com/surgeventures/confix/commits/master)

***Read, parse and patch Elixir application's configuration***

Features:

- Get Mix config for your application in the most compact way
- Parse `{:system, "ENV_VAR"}` tuples automatically for runtime config capabilities
- Cast system tuples to specific type and provide defaults
- Load config via system tuples from multiple env vars, taking first present one
- Patch external library configs with all the above capabilities

## Getting Started

Add `:confix` as a dependency to your project in `mix.exs`:

```elixir
defp deps do
  [
    {:confix, "~> 0.4"}
  ]
end
```

Then run `mix deps.get` to fetch it.

<!-- MDOC !-->

## Usage

In order to get values, you may first add dynamic configuration to `config/prod.exs`:

```elixir
config :confix,
  base_app: :my_project # defaults to Mix app, so it's usually not needed

config :my_project,
  feature_x_enabled: {:system, "FEATURE_X_ENABLED", type: :boolean, default: false}

config :my_project, MyProject.Web.Endpoint,
  pubsub: [url: {:system, "REDIS_URL"}]
```

You may get these values in your own code:

```elixir
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
```

You may also want to parse arbitrary configuration that doesn't come from Mix:

```elixir
iex> System.put_env("ADAPTER_URL", "http://example.com")
:ok

iex> Confix.parse({:system, "ADAPTER_URL"})
"http://example.com"

iex> Confix.deep_parse(adapter: [url: {:system, "ADAPTER_URL"}])
[adapter: [url: "http://example.com"]]
```

Sometimes however the place where you'd like system tuples to be read lies outside your own code
and in 3rd party applications that don't natively support them. That could be (and actually is)
the case of `MyProject.Web.Endpoint` on examples above - the Redis adapter for Phoenix PubSub
doesn't properly parse the system tuples. In such cases, 3rd party config can be easily patched
with `Confix.Application`.

## Usage in modules

You may also `use Confix` in your own modules in order to have quick means for getting config
associated with that particular module:

```elixir
defmodule MyProject.MyHTTPClient do
  use Confix

  def call do
    url = config!(:url)

    # ...
  end
end
```

## Syntax

System tuples may have the following syntax:

```elixir
{:system, "ENV_VAR"}
{:system, "ENV_VAR", default: "xyz"}
{:system, "ENV_VAR", type: :integer}
{:system, "ENV_VAR", type: :boolean, default: true}
{:system, ["ENV_VAR_1", "ENV_VAR_2"]}
```

<!-- MDOC !-->

## Documentation

Visit documentation on [HexDocs](https://hexdocs.pm/confix) for a complete API reference.

## Copyright and License

Copyright (c) 2017 Surge Ventures

This library is released under the MIT License. See the [LICENSE.md](./LICENSE.md) file
for further details.
