defmodule SmartTrashBinServerWeb.TrashCapacityHistoryController do
  use SmartTrashBinServerWeb, :controller

  alias SmartTrashBinServer.TrashCapacityHistories.CreateOperation
  require Logger

  def create(%Plug.Conn{assigns: %{imsi: imsi}} = conn, %{"distance" => distance}) do
    case %{imsi: imsi, distance: distance} |> CreateOperation.call() do
      {:ok, _trash_capacity_history} ->
        conn |> send_resp(:ok, "ok")

      {:error, _reason} ->
        conn |> send_resp(:unprocessable_entity, "Unprocessable Entity")
    end
  end
end
