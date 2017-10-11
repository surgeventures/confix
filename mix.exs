defmodule Confix.Mixfile do
  use Mix.Project

  def project do
    [app: :confix,
     version: "0.2.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     aliases: aliases(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       check: :test,
       coveralls: :test,
       "coveralls.detail": :test,
       "coveralls.html": :test],
     name: "Confix",
     description: "Application config getter and fixer aka. Mix config on steroids",
     source_url: "https://github.com/surgeventures/confix",
     homepage_url: "https://github.com/surgeventures/confix",
     docs: [main: "readme",
            extras: ["README.md"]]]
  end

  defp package do
    [maintainers: ["Karol Słuszniak"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/surgeventures/confix",
       "Shedul" => "https://www.shedul.com"
     },
     files: ~w(mix.exs lib LICENSE.md README.md)]
  end

  def application do
    [mod: {Confix.Application, []},
     extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp aliases do
    [
      "check": check_alias(),
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.8.1", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:excoveralls, "~> 0.7", only: :test},
    ]
  end

  defp check_alias do
    [
      "compile --warnings-as-errors --force",
      "test",
      "credo --strict",
    ]
  end
end
