defmodule SmartTrashBinServer.Repo.Migrations.AddCapacityRateToTrashCapacityHistory do
  use Ecto.Migration

  def change do
    alter table(:trash_capacity_histories) do
      add(:capacity_rate, :integer, default: 0, null: false)
    end
  end
end
