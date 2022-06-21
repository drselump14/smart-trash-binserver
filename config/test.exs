import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :smart_trash_bin_server, SmartTrashBinServer.Repo,
  username: "postgres",
  password: "postgres",
  database: "smart_trash_bin_server_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  types: SmartTrashBinServer.PostgresTypes

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :smart_trash_bin_server, SmartTrashBinServerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :smart_trash_bin_server, Oban, testing: :inline

config :smart_trash_bin_server, SmartTrashBinServer.Mailer, adapter: Bamboo.TestAdapter
