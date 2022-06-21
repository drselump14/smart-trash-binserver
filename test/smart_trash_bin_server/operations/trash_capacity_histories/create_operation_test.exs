defmodule SmartTrashBinServer.Operations.TrashCapacityHistories.CreateOperationTest do
  use SmartTrashBinServer.DataCase
  use Bamboo.Test

  alias SmartTrashBinServer.Email
  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.TrashCapacityHistories.CreateOperation
  alias SmartTrashBinServer.TrashCapacityHistory

  describe "when capacity_rate is above 80" do
    setup [
      :setup_trash_bin,
      :setup_full_trash_capacity_history,
      :setup_params
    ]

    test "call", %{params: params} do
      assert {:ok, history_capacity} = params |> CreateOperation.call()

      email = history_capacity |> Repo.preload(:trash_bin) |> Email.notify_full_trash_bin()

      assert_delivered_email(email)
    end
  end

  describe "when capacity_rate is below 80" do
    setup [
      :setup_trash_bin,
      :setup_empty_trash_capacity_history,
      :setup_params
    ]

    test "call", %{params: params} do
      assert {:ok, history_capacity} = params |> CreateOperation.call()

      email = history_capacity |> Repo.preload(:trash_bin) |> Email.notify_full_trash_bin()

      refute_delivered_email(email)
    end
  end

  describe "when it receives invalid sensor value" do
    setup [
      :setup_trash_bin,
      :setup_invalid_trash_capacity_history,
      :setup_params
    ]

    test "call", %{params: params} do
      assert {:error, :invalid_sensor_value} = params |> CreateOperation.call()
    end
  end

  defp setup_params(
         %{
           trash_bin: %TrashBin{imsi: imsi},
           capacity: %TrashCapacityHistory{distance: distance}
         } = context
       ) do
    context
    |> Map.put(:params, %{imsi: imsi, distance: distance})
  end
end
