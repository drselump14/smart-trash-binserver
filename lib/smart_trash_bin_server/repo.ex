defmodule SmartTrashBinServer.Repo do
  use Ecto.Repo,
    otp_app: :smart_trash_bin_server,
    adapter: Ecto.Adapters.Postgres
end
