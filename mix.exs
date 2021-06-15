defmodule Alice.Mixfile do
  use Mix.Project

  @version "0.4.3"

  def project do
    [
      app: :alice,
      version: @version,
      elixir: "~> 1.7",
      deps: deps(),
      package: package(),
      consolidate_protocols: Mix.env() != :test,
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Alice",
      docs: docs(),
      preferred_cli_env: [
        docs: :docs,
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      test_coverage: [tool: ExCoveralls],
      source_url: "https://github.com/alice-bot/alice",
      homepage_url: "https://www.alice-bot.org",
      description: "A Slack bot"
    ]
  end

  defp elixirc_paths(:docs), do: ~w(lib installer/lib)
  defp elixirc_paths(_env), do: ~w(lib)

  def application do
    [
      extra_applications: [:logger, :mix],
      env: [logger: true]
    ]
  end

  defp deps do
    [
      {:slack, "~> 0.23.2"},
      {:poison, "~> 4.0"},
      {:poolboy, "~> 1.5.0"},
      {:redix, "~> 1.1.3"},

      # Optional dependencies
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false, optional: true},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false, optional: true},

      # Test dependencies
      {:excoveralls, "~> 0.12.3", only: :test},

      # Docs dependencies
      {:ex_doc, "~> 0.21", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Adam Zaninovich"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/alice-bot/alice"},
      files: ~w(lib CHANGELOG.md LICENSE config mix.exs README.md .formatter.exs)
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      logo: "resources/logo.png"
    ]
  end
end
