defmodule SmartTrashBinServer.Repo.Migrations.AddStaticMapLocationToTrashBin do
  use Ecto.Migration

  def change do
    alter table(:trash_bins) do
      add(:left, :integer)
      add(:top, :integer)
    end
  end
end
