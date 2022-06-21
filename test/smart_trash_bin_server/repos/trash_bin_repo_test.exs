defmodule SmartTrashBinServer.Repos.TrashBinRepoTest do
  use SmartTrashBinServer.DataCase

  alias SmartTrashBinServer.Factory
  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.TrashBinRepo
  alias SmartTrashBinServer.TrashCapacityHistory

  @valid_attrs %{
    description: "some description",
    empty_distance: 42,
    imsi: "some imsi",
    left: 42,
    name: "some name",
    sensor_and_bucket_distance: 42,
    sim_id: "some sim_id",
    top: 42
  }
  @update_attrs %{
    description: "some updated description",
    empty_distance: 43,
    imsi: "some updated imsi",
    left: 43,
    name: "some updated name",
    sensor_and_bucket_distance: 43,
    sim_id: "some updated sim_id",
    top: 43
  }
  @invalid_attrs %{
    description: nil,
    empty_distance: nil,
    imsi: nil,
    left: nil,
    name: nil,
    sensor_and_bucket_distance: nil,
    sim_id: nil,
    top: nil
  }

  describe "#paginate_trash_bins/1" do
    test "returns paginated list of trash_bins" do
      for _ <- 1..20 do
        trash_bin_fixture()
      end

      {:ok, %{trash_bins: trash_bins} = page} = TrashBinRepo.paginate_trash_bins(%{})

      assert length(trash_bins) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_trash_bins/0" do
    test "returns all trash_bins" do
      trash_bin = trash_bin_fixture()
      assert TrashBinRepo.list_trash_bins() |> Enum.member?(trash_bin)
    end
  end

  describe "#get_trash_bin!/1" do
    test "returns the trash_bin with given id" do
      trash_bin = trash_bin_fixture()
      assert TrashBinRepo.get_trash_bin!(trash_bin.id) == trash_bin
    end
  end

  describe "#create_trash_bin/1" do
    test "with valid data creates a trash_bin" do
      assert {:ok, %TrashBin{} = trash_bin} = TrashBinRepo.create_trash_bin(@valid_attrs)
      assert trash_bin.description == "some description"
      assert trash_bin.empty_distance == 42
      assert trash_bin.imsi == "some imsi"
      assert trash_bin.left == 42
      assert trash_bin.name == "some name"
      assert trash_bin.sensor_and_bucket_distance == 42
      assert trash_bin.sim_id == "some sim_id"
      assert trash_bin.top == 42
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TrashBinRepo.create_trash_bin(@invalid_attrs)
    end
  end

  describe "#update_trash_bin/2" do
    test "with valid data updates the trash_bin" do
      trash_bin = trash_bin_fixture()
      assert {:ok, trash_bin} = TrashBinRepo.update_trash_bin(trash_bin, @update_attrs)
      assert %TrashBin{} = trash_bin
      assert trash_bin.description == "some updated description"
      assert trash_bin.empty_distance == 43
      assert trash_bin.imsi == "some updated imsi"
      assert trash_bin.left == 43
      assert trash_bin.name == "some updated name"
      assert trash_bin.sensor_and_bucket_distance == 43
      assert trash_bin.sim_id == "some updated sim_id"
      assert trash_bin.top == 43
    end

    test "with invalid data returns error changeset" do
      trash_bin = trash_bin_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TrashBinRepo.update_trash_bin(trash_bin, @invalid_attrs)

      assert trash_bin == TrashBinRepo.get_trash_bin!(trash_bin.id)
    end
  end

  describe "#delete_trash_bin/1" do
    test "deletes the trash_bin" do
      trash_bin = trash_bin_fixture()
      assert {:ok, %TrashBin{}} = TrashBinRepo.delete_trash_bin(trash_bin)
      assert_raise Ecto.NoResultsError, fn -> TrashBinRepo.get_trash_bin!(trash_bin.id) end
    end
  end

  describe "#change_trash_bin/1" do
    test "returns a trash_bin changeset" do
      trash_bin = trash_bin_fixture()
      assert %Ecto.Changeset{} = TrashBinRepo.change_trash_bin(trash_bin)
    end
  end

  describe "dead_trash_bins_query" do
    setup [
      :setup_trash_bin,
      :setup_full_trash_capacity_history
    ]

    test "should include a trash_bin with no capacity_history", %{
      trash_bin: trash_bin_with_capacity_history
    } do
      trash_bin_with_no_capacity_history = Factory.insert(:trash_bin)
      dead_trash_bins = TrashBinRepo.dead_trash_bins_query() |> Repo.all()
      refute dead_trash_bins |> Enum.member?(trash_bin_with_capacity_history)
      assert dead_trash_bins |> Enum.member?(trash_bin_with_no_capacity_history)
    end

    test "should include a trash bin with old capacity_history", %{
      trash_bin: trash_bin_with_capacity_history,
      capacity: capacity
    } do
      yesterday = Timex.now() |> Timex.shift(days: -1)

      # update capacity_history to yesterday
      capacity |> TrashCapacityHistory.changeset(%{inserted_at: yesterday}) |> Repo.update!()

      assert TrashBinRepo.dead_trash_bins_query()
             |> Repo.all()
             |> Enum.member?(trash_bin_with_capacity_history)
    end
  end

  describe "update_dead_node_status" do
    setup [
      :setup_trash_bin,
      :setup_full_trash_capacity_history
    ]

    test "should update the trash_bin with no capacity_history", %{
      trash_bin: trash_bin_with_capacity_history
    } do
      trash_bin_with_no_capacity_history = Factory.insert(:trash_bin)

      TrashBinRepo.dead_trash_bins_query()
      |> Repo.all()
      |> Enum.map(& &1.id)
      |> TrashBinRepo.update_dead_node_status()

      assert %TrashBin{dead: true} = TrashBin |> Repo.get(trash_bin_with_no_capacity_history.id)
      assert %TrashBin{dead: false} = TrashBin |> Repo.get(trash_bin_with_capacity_history.id)
    end
  end

  def trash_bin_fixture(attrs \\ %{}) do
    Factory.insert(:trash_bin, attrs)
  end
end
