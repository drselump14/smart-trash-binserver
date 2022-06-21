defmodule SmartTrashBinServer.Repo.Migrations.AddDeadFlagToTrashBin do
  use Ecto.Migration

  def change do
    alter table(:trash_bins) do
      add(:dead, :boolean, default: false)
    end
  end
end
