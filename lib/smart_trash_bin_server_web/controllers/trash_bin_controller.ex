defmodule SmartTrashBinServerWeb.TrashBinsController do
  use SmartTrashBinServerWeb, :controller

  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.TrashBinRepo

  plug(:put_root_layout, {SmartTrashBinServerWeb.LayoutView, "torch.html"})
  plug(:put_layout, false)

  def index(conn, params) do
    case TrashBinRepo.paginate_trash_bins(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        conn
        |> put_flash(:error, "There was an error rendering Trash bins. #{inspect(error)}")
        |> redirect(to: Routes.trash_bins_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = TrashBinRepo.change_trash_bin(%TrashBin{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"trash_bin" => trash_bin_params}) do
    case TrashBinRepo.create_trash_bin(trash_bin_params) do
      {:ok, trash_bin} ->
        conn
        |> put_flash(:info, "Trash bin created successfully.")
        |> redirect(to: Routes.trash_bins_path(conn, :show, trash_bin))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    trash_bin = TrashBinRepo.get_trash_bin!(id)
    render(conn, "show.html", trash_bin: trash_bin)
  end

  def edit(conn, %{"id" => id}) do
    trash_bin = TrashBinRepo.get_trash_bin!(id)
    changeset = TrashBinRepo.change_trash_bin(trash_bin)
    render(conn, "edit.html", trash_bin: trash_bin, changeset: changeset)
  end

  def update(conn, %{"id" => id, "trash_bin" => trash_bin_params}) do
    trash_bin = TrashBinRepo.get_trash_bin!(id)

    case TrashBinRepo.update_trash_bin(trash_bin, trash_bin_params) do
      {:ok, trash_bin} ->
        conn
        |> put_flash(:info, "Trash bin updated successfully.")
        |> redirect(to: Routes.trash_bins_path(conn, :show, trash_bin))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", trash_bin: trash_bin, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    trash_bin = TrashBinRepo.get_trash_bin!(id)
    {:ok, _trash_bin} = TrashBinRepo.delete_trash_bin(trash_bin)

    conn
    |> put_flash(:info, "Trash bin deleted successfully.")
    |> redirect(to: Routes.trash_bins_path(conn, :index))
  end
end
