defmodule SmartTrashBinServer.Repo.Migrations.CreateTrashBinTable do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS postgis")

    create table(:trash_bins) do
      add(:sim_id, :string, null: false)
      add(:imsi, :string, null: false)
      add(:name, :string, null: false)
      add(:description, :text)

      timestamps()
    end

    create(index(:trash_bins, [:sim_id, :imsi]))
    create(index(:trash_bins, [:sim_id], unique: true))
    create(index(:trash_bins, [:imsi], unique: true))

    # Add a field `point` with type `geometry(Point,4326)`.
    # This can store a "standard GPS" (epsg4326) coordinate pair {longitude,latitude}.
    execute("SELECT AddGeometryColumn ('trash_bins','location',4326,'POINT',2)")
    execute("CREATE INDEX trash_bins_location_index on trash_bins USING gist (location)")
  end

  def down do
    drop(table(:trash_bins))
    execute("DROP EXTENSION IF EXISTS postgis")
  end
end
