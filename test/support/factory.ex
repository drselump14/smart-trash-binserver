defmodule SmartTrashBinServer.Factory do
  @moduledoc """
  Factory modules for testing
  """

  use ExMachina.Ecto, repo: SmartTrashBinServer.Repo

  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.TrashCapacityHistory

  def trash_bin_factory do
    %TrashBin{
      name: sequence(:name, &"#{&1}) trash bin #{&1}"),
      empty_distance: 800,
      sensor_and_bucket_distance: 400,
      sim_id: Faker.UUID.v4(),
      imsi: Faker.UUID.v4(),
      left: 0,
      top: 0
    }
  end

  def trash_capacity_history_factory do
    %TrashCapacityHistory{
      trash_bin: build(:trash_bin),
      distance: Faker.random_between(100, 900)
    }
  end
end
