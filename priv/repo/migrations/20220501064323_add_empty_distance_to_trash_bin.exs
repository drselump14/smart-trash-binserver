defmodule SmartTrashBinServer.Repo.Migrations.AddEmptyDistanceToTrashBin do
  use Ecto.Migration

  def change do
    alter table(:trash_bins) do
      add(:empty_distance, :integer, default: 0, null: false)
      add(:sensor_and_bucket_distance, :integer, default: 0, null: false)
    end
  end
end
