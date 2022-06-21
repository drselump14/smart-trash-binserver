defmodule SmartTrashBinServer.Repo.Migrations.AddRaidenNodeUrlToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:raiden_node_url, :string)
    end
  end
end
