defmodule SmartTrashBinServerWeb.TrashBinControllerTest do
  use SmartTrashBinServerWeb.ConnCase

  alias SmartTrashBinServer.TrashBinRepo

  @create_attrs %{
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

  def fixture(:trash_bin) do
    {:ok, trash_bin} = TrashBinRepo.create_trash_bin(@create_attrs)
    trash_bin
  end

  setup [:register_and_log_in_user]

  describe "index" do
    test "lists all trash_bins", %{conn: conn} do
      conn = get(conn, Routes.trash_bins_path(conn, :index))
      assert html_response(conn, 200) =~ "Trash bins"
    end
  end

  describe "new trash_bin" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.trash_bins_path(conn, :new))
      assert html_response(conn, 200) =~ "New Trash bin"
    end
  end

  describe "create trash_bin" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.trash_bins_path(conn, :create), trash_bin: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.trash_bins_path(conn, :show, id)

      conn = get(conn, Routes.trash_bins_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Trash bin Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.trash_bins_path(conn, :create), trash_bin: @invalid_attrs
      assert html_response(conn, 200) =~ "New Trash bin"
    end
  end

  describe "edit trash_bin" do
    setup [:create_trash_bin]

    test "renders form for editing chosen trash_bin", %{conn: conn, trash_bin: trash_bin} do
      conn = get(conn, Routes.trash_bins_path(conn, :edit, trash_bin))
      assert html_response(conn, 200) =~ "Edit Trash bin"
    end
  end

  describe "update trash_bin" do
    setup [:create_trash_bin]

    test "redirects when data is valid", %{conn: conn, trash_bin: trash_bin} do
      conn = put conn, Routes.trash_bins_path(conn, :update, trash_bin), trash_bin: @update_attrs
      assert redirected_to(conn) == Routes.trash_bins_path(conn, :show, trash_bin)

      conn = get(conn, Routes.trash_bins_path(conn, :show, trash_bin))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, trash_bin: trash_bin} do
      conn = put conn, Routes.trash_bins_path(conn, :update, trash_bin), trash_bin: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Trash bin"
    end
  end

  describe "delete trash_bin" do
    setup [:create_trash_bin]

    test "deletes chosen trash_bin", %{conn: conn, trash_bin: trash_bin} do
      conn = delete(conn, Routes.trash_bins_path(conn, :delete, trash_bin))
      assert redirected_to(conn) == Routes.trash_bins_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.trash_bins_path(conn, :show, trash_bin))
      end
    end
  end

  defp create_trash_bin(_) do
    trash_bin = fixture(:trash_bin)
    {:ok, trash_bin: trash_bin}
  end
end
