defmodule SmartTrashBinServer.Repo.Migrations.CreateTrashCapacityHistoriesTable do
  use Ecto.Migration

  def up do
    create table(:trash_capacity_histories) do
      add(:distance, :decimal, null: false)
      add(:imsi, references(:trash_bins, column: :imsi, type: :string))

      timestamps(
        type: :utc_datetime,
        updated_at: false
      )
    end

    create(index(:trash_capacity_histories, [:imsi]))

    execute(
      "SELECT create_hypertable('trash_capacity_histories', 'id', chunk_time_interval => 100000)"
    )
  end

  def down do
    drop(table(:trash_capacity_histories))
  end
end
