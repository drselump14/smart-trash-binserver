defmodule SmartTrashBinServer.Repo.Migrations.ConvertDistanceColumnFromNumericToInteger do
  use Ecto.Migration

  def change do
    alter table(:trash_capacity_histories) do
      modify(:distance, :integer)
    end
  end
end
