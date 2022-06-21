defmodule SmartTrashBinServer.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :smart_trash_bin_server,
      compilers: [:phoenix, :gettext] ++ Mix.compilers() ++ [:surface],
      deps: deps(),
      dialyzer: [plt_add_apps: [:ex_unit, :mix], ignore_warnings: "config/dialyzer.ignore"],
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [
        coverals: :test,
        "coverals.detail": :test,
        "coverals.html": :test,
        "coverals.post": :test,
        "vcr.check": :test,
        "vcr.delete": :test,
        "vcr.show": :test,
        vcr: :test
      ],
      test_coverage: [tool: ExCoveralls],
      version: "0.1.0"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SmartTrashBinServer.Application, []},
      extra_applications: [:logger, :runtime_tools, :bamboo]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"] ++ catalogues()
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bamboo, "~> 2.2.0"},
      {:bamboo_phoenix, "~> 1.0"},
      {:bamboo_smtp, "~> 4.1.0"},
      {:bcrypt_elixir, "~> 2.0"},
      {:contex, github: "mindok/contex"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.7.2"},
      {:ecto_adapters_dynamodb, "~> 3.1.2"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_guard, "~> 1.5", only: :dev},
      {:ex_machina, "~> 2.7.0"},
      {:exvcr, "~> 0.13.3", only: :test},
      {:faker, "~> 0.17"},
      {:floki, ">= 0.27.0", only: :test},
      {:geo, "~> 3.4.3"},
      {:geo_postgis, "~> 3.4"},
      {:gettext, "~> 0.11"},
      {:git_hooks, "~> 0.6.2", only: [:dev], runtime: false},
      {:hackney, "~> 1.17.0"},
      {:jason, "~> 1.1"},
      {:matrix_sdk, git: "https://github.com/niklaslong/matrix-elixir-sdk", branch: "master"},
      {:mox, "~> 1.0", only: :test},
      {:oban, "~> 2.12.0"},
      {:phoenix, "~> 1.6.6"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "~> 3.2.0"},
      {:phoenix_live_dashboard, "~> 0.6.5"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.7"},
      {:plug_cowboy, "~> 2.3"},
      {:postgrex, ">= 0.0.0"},
      {:rewire, "~> 0.5", only: :test},
      {:surface, "~> 0.7.1"},
      {:sentry, "~> 8.0"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6.1"},
      {:telemetry_poller, "~> 1.0.0"},
      {:tesla, "~> 1.4.4"},
      {:timex, "~> 3.7.1"},
      {:torch, "~> 4.0"},
      {:tortoise, "~> 0.9"},
      {:typed_struct, "~> 0.2.1"},
      {:surface_formatter, "~> 0.7.4"},
      {:surface_catalogue, "~> 0.3.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  def catalogues do
    [
      "priv/catalogue"
    ]
  end
end
