use Mix.Config

if Mix.env == :test do
  config :logger, level: :info

 config :confix, ConfixTest.ConfixTestMod,
    key: :value,
    nest_key: [
      nest_value: :deep_value
    ]

  config :confix, :config_test,
    filled_key: "filled value",
    system_key_without_default: {:system, "NON_EXISTING_ENV_VAR"},
    system_key_with_default: {:system, "NON_EXISTING_ENV_VAR", default: "default value"},
    system_key_with_boolean_type: {:system, "BOOLEAN_ENV_VAR", type: :boolean},
    system_key_with_integer_type: {:system, "INTEGER_ENV_VAR", type: :integer}

  config :confix,
    flat_config_key: "flat value"
end
