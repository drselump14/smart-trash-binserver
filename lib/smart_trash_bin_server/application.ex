defmodule SmartTrashBinServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SmartTrashBinServer.Repo,
      # Start the Telemetry supervisor
      SmartTrashBinServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SmartTrashBinServer.PubSub},
      # Start MQTT Client
      # {Tortoise.Connection,
      #  [
      #    client_id: SmartTrashBinServer,
      #    server: {Tortoise.Transport.Tcp, host: "test.mosquitto.org", port: 1883},
      #    handler: {Tortoise.Handler.Logger, []}
      #  ]},
      # Start the Endpoint (http/https)
      SmartTrashBinServerWeb.Endpoint,
      {Oban, oban_config()}
      # Start a worker by calling: SmartTrashBinServer.Worker.start_link(arg)
      # {SmartTrashBinServer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmartTrashBinServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SmartTrashBinServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def oban_config do
    Application.fetch_env!(:smart_trash_bin_server, Oban)
  end
end
