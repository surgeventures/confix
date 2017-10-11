# Confix

***Application config getter and fixer aka. Mix config on steroids***

Features:

- Get Mix config for your application in the most compact way
- Parse `{:system, "ENV_VAR"}` tuples automatically for runtime config capabilities
- Cast system tuples to specific type and provide defaults
- Load config via system tuples from multiple env vars, taking first present one
- Patch external library configs with all the above capabilities

## Getting Started

Add `confix` as a dependency to your project in `mix.exs`:

```elixir
defp deps do
  [{:confix, "~> x.x.x"}]
end
```

Then run `mix deps.get` to fetch it.

## Documentation

Visit documentation on [HexDocs](https://hexdocs.pm/confix) for a complete API reference.

