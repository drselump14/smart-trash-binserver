# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :smart_trash_bin_server,
  ecto_repos: [
    SmartTrashBinServer.Repo
  ]

config :smart_trash_bin_server, SmartTrashBinServer.Repo,
  extensions: [{Geo.PostGIS.Extension, library: Geo}]

# Configures the endpoint
config :smart_trash_bin_server, SmartTrashBinServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VdJp1XG4UO4ObiugJfdHVMzil/z7UucWyTllMfE2gNLMu1/DvseUO2Af6U7WS4Gw",
  render_errors: [view: SmartTrashBinServerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SmartTrashBinServer.PubSub,
  live_view: [signing_salt: "m4TYbuKk"]

config :smart_trash_bin_server, SmartTrashBinServer.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: {:system, "SENDGRID_API_KEY"},
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ]

config :torch,
  otp_app: :smart_trash_bin_server,
  template_format: "eex"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :surface, :components, [
  {Surface.Components.Form.ErrorTag,
   default_translator: {SmartTrashBinServerWeb.ErrorHelpers, :translate_error}}
]

config(:tesla, adapter: Tesla.Adapter.Hackney)

config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.0.23",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :smart_trash_bin_server, :soracom, pre_shared_key: System.get_env("SORACOM_PRE_SHARED_KEY")

config :torch, otp_app: :smart_trash_bin_server, template_format: "heex"

if config_env() == :dev do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          {:cmd, "mix compile --warning-as-errors"},
          {:cmd, "mix format --check-formatted"},
          {:cmd, "mix credo --strict suggest"}
        ]
      ],
      pre_push: [
        tasks: [
          {:cmd, "mix dialyzer"},
          {:cmd, "mix test --color"},
          {:cmd, "echo 'success!'"}
        ]
      ]
    ]
end

config :smart_trash_bin_server, Oban,
  repo: SmartTrashBinServer.Repo,
  plugins: [
    Oban.Plugins.Pruner,
    {Oban.Plugins.Cron,
     crontab: [
       # Every 11:00 JST
       # {"0 2 * * *", SmartTrashBinServer.CheckDeadNodeWorker}
     ]}
  ],
  queues: [default: 10, events: 50, media: 20]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
