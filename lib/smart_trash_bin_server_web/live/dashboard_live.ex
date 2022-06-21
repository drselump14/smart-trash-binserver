defmodule SmartTrashBinServerWeb.DashboardLive do
  @moduledoc """
  Page live
  """
  use Surface.LiveView

  alias SmartTrashBinServer.Repo
  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.TrashBinRepo
  alias SmartTrashBinServer.TrashCapacityHistory
  alias SmartTrashBinServer.TrashCapacityHistoryRepo
  alias SmartTrashBinServer.TrashCapacityPubSub
  alias SmartTrashBinServerWeb.ChartComponent

  alias SmartTrashBinServerWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do
    if connected?(socket) do
      TrashCapacityPubSub.subscribe()
    end

    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
    <div class="m-2 lg:m-5 grid grid-cols-1 lg:grid-cols-2">
      <div id="staticMap" phx-hook="StaticMap" phx-update="ignore" data-markers={trashbin_marker_datasets()}>
        <img id="sampleImage" src={Routes.static_path(SmartTrashBinServerWeb.Endpoint, "/images/chiba-zoo-map.jpg")} crossorigin="anonymous" />
      </div>
      <div class="grid grid-cols-1 lg:grid-cols-1">
        {#for dataset <- trash_capacity_history_datasets()}
          <ChartComponent imsi={dataset.imsi} dataset={dataset}/>
        {/for}
      </div>
    </div>
    """
  end

  def trash_capacity_history_datasets do
    TrashCapacityHistoryRepo.chart_datasets() |> Enum.sort_by(& &1.label)
  end

  def trashbin_marker_datasets do
    TrashBinRepo.marker_datasets() |> Jason.encode!()
  end

  def handle_info(
        {:trash_capacity_history_inserted,
         %TrashCapacityHistory{distance: distance, imsi: imsi, inserted_at: inserted_at}},
        socket
      ) do
    trash_bin = TrashBin |> Repo.get_by!(imsi: imsi)

    {
      :noreply,
      push_event(
        socket,
        "new-point" <> "-" <> imsi,
        %{label: trash_bin.name, value: distance, insertedAt: inserted_at}
      )
    }
  end

  def handle_info(
        {:trash_capacity_history_updated,
         %TrashCapacityHistory{
           distance: distance,
           imsi: imsi,
           capacity_rate: capacity_rate
         }},
        socket
      ) do
    {
      :noreply,
      push_event(
        socket,
        "update-point",
        %{imsi: imsi, distance: distance, capacity_rate: capacity_rate}
      )
    }
  end
end
