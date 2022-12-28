defmodule Confix.Mixfile do
  use Mix.Project

  @source_url "https://github.com/surgeventures/confix"
  @version "0.4.1"

  def project do
    [
      app: :confix,
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      aliases: aliases(),
      preferred_cli_env: [
        check: :test,
        docs: :docs
      ],
      name: "Confix",
      docs: docs()
    ]
  end

  defp package do
    [
      description: "Read, parse and patch Elixir application's configuration",
      licenses: ["MIT"],
      files: ~w(mix.exs lib LICENSE.md README.md),
      links: %{
        "GitHub" => @source_url,
        "Fresha" => "https://www.fresha.com"
      },
    ]
  end

  def application do
    [mod: {Confix.Application, []}, extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      check: check_alias()
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false}
    ]
  end

  defp check_alias do
    [
      "format --check-formatted",
      "compile --warnings-as-errors --force",
      "test",
      "credo --strict"
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [title: "Changelog"],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      homepage_url: @source_url,
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
