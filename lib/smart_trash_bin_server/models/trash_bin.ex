defmodule SmartTrashBinServer.TrashBin do
  @moduledoc """
  Schema for modeling TrashBin
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias SmartTrashBinServer.TrashCapacityHistory

  schema "trash_bins" do
    field :sim_id, :string, null: false
    field :imsi, :string, null: false
    field :name, :string, null: false
    field :description, :string
    field :location, Geo.PostGIS.Geometry
    field :left, :integer
    field :top, :integer
    field :dead, :boolean, default: false

    field :empty_distance, :integer,
      null: false,
      default: 0,
      description: "distance of empty bucket"

    field :sensor_and_bucket_distance, :integer, null: false, default: 0

    timestamps()

    has_one :latest_capacity_history, {"trash_capacity_histories", TrashCapacityHistory},
      foreign_key: :imsi,
      references: :imsi,
      preload_order: [desc: :id]

    has_many :trash_capacity_histories, {"trash_capacity_histories", TrashCapacityHistory},
      foreign_key: :imsi,
      references: :imsi,
      preload_order: [desc: :id]
  end

  def changeset(trash_bin, attrs) do
    trash_bin
    |> cast(attrs, [
      :sim_id,
      :imsi,
      :name,
      :description,
      :location,
      :left,
      :top,
      :empty_distance,
      :sensor_and_bucket_distance,
      :dead
    ])
    |> validate_required([:sim_id, :imsi, :name])
  end
end
