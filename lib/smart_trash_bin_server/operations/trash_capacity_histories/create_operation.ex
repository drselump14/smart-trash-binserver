defmodule SmartTrashBinServer.TrashCapacityHistories.CreateOperation do
  @moduledoc """
  Operation to create trash_capacity_history
  """

  alias SmartTrashBinServer.Email
  alias SmartTrashBinServer.Mailer
  alias SmartTrashBinServer.Repo
  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.TrashCapacityHistory
  alias SmartTrashBinServer.TrashCapacityPubSub

  require Logger

  #
  # Skip the process if sensor value is more than 8_000
  #
  def call(%{distance: distance}) when distance > 7_000 do
    Logger.info("invalid_sensor_value")
    {:error, :invalid_sensor_value}
  end

  def call(params) do
    params
    |> insert_history()
    |> send_warning_email()
    |> TrashCapacityPubSub.notify_subscriber(:trash_capacity_history_inserted)
    |> TrashCapacityPubSub.notify_subscriber(:trash_capacity_history_updated)
  end

  def insert_history(%{imsi: imsi, distance: distance} = params) do
    %TrashBin{
      empty_distance: empty_distance,
      sensor_and_bucket_distance: sensor_and_bucket_distance
    } = TrashBin |> Repo.get_by!(imsi: imsi)

    capacity_rate =
      TrashCapacityHistory.calc_capacity_rate(
        distance,
        empty_distance,
        sensor_and_bucket_distance
      )

    params = params |> Map.put(:capacity_rate, capacity_rate)

    %TrashCapacityHistory{}
    |> TrashCapacityHistory.changeset(params)
    |> Repo.insert(returning: false)
  end

  def send_warning_email({:ok, %TrashCapacityHistory{capacity_rate: capacity_rate} = capacity})
      when capacity_rate > 80 do
    capacity
    |> Repo.preload(:trash_bin)
    |> Email.notify_full_trash_bin()
    |> Mailer.deliver_now!()

    {:ok, capacity}
  end

  def send_warning_email({:ok, %TrashCapacityHistory{} = capacity}),
    do: {:ok, capacity}
end
