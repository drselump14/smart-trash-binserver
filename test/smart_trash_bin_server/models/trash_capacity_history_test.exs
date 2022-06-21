defmodule SmartTrashBinServer.Models.TrashCapacityHistoryTest do
  use SmartTrashBinServer.DataCase

  alias SmartTrashBinServer.Factory
  alias SmartTrashBinServer.Repo
  alias SmartTrashBinServer.TrashCapacityHistory

  describe "when trash_bin is not loaded" do
    setup [:setup_trash_bin]

    test "capacity_rate" do
      :trash_capacity_history |> Factory.insert()
      query = from(capacity in TrashCapacityHistory)
      capacity = query |> Repo.one()

      # Make sure that capacity trash_bin is not loaded
      refute capacity.trash_bin |> Ecto.assoc_loaded?()

      assert capacity |> TrashCapacityHistory.capacity_rate()
    end
  end

  describe "when latest_capacity_history present and full" do
    setup [:setup_trash_bin, :setup_full_trash_capacity_history]

    test "capacity_rate", %{capacity: capacity} do
      assert capacity |> TrashCapacityHistory.capacity_rate() == 100
    end
  end

  describe "when latest_capacity_history present and empty" do
    setup [:setup_trash_bin, :setup_empty_trash_capacity_history]

    test "capacity_rate", %{capacity: capacity} do
      assert capacity |> TrashCapacityHistory.capacity_rate() == 0
    end
  end
end
