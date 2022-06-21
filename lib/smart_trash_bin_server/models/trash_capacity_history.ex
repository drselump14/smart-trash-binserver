defmodule SmartTrashBinServer.TrashCapacityHistory do
  @moduledoc """
  Schema for recording Trash Capacity
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias SmartTrashBinServer.Repo
  alias SmartTrashBinServer.TrashBin

  schema "trash_capacity_histories" do
    belongs_to :trash_bin, TrashBin,
      foreign_key: :imsi,
      references: :imsi,
      type: :string

    # in milimeter
    field :distance, :integer

    field :capacity_rate, :integer,
      null: false,
      default: 0,
      description: "Capacity rate (100 is full, 0 is empty)"

    timestamps(updated_at: false)
  end

  def changeset(trash_capacity_history, attrs) do
    trash_capacity_history
    |> cast(attrs, [:imsi, :distance, :capacity_rate, :inserted_at])
    |> validate_required([:imsi, :distance, :capacity_rate])
  end

  def calc_capacity_rate(nil, _empty_distance, _sensor_and_bucket_distance) do
    0
  end

  def calc_capacity_rate(distance, empty_distance, sensor_and_bucket_distance) do
    empty_percentage = (distance - sensor_and_bucket_distance) / empty_distance

    (100 - empty_percentage * 100) |> round()
  end

  def capacity_rate(%__MODULE__{
        distance: distance,
        trash_bin: %TrashBin{
          empty_distance: empty_distance,
          sensor_and_bucket_distance: sensor_and_bucket_distance
        }
      }) do
    distance |> calc_capacity_rate(empty_distance, sensor_and_bucket_distance)
  end

  def capacity_rate(
        %__MODULE__{
          trash_bin: %Ecto.Association.NotLoaded{}
        } = capacity
      ) do
    capacity
    |> Repo.preload(:trash_bin)
    |> capacity_rate()
  end
end
