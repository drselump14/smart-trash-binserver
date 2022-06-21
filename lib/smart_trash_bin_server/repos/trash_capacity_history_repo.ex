defmodule SmartTrashBinServer.TrashCapacityHistoryRepo do
  @moduledoc """
  Repo for TrashCapacityHistory
  """

  import Ecto.Query, warn: false

  alias SmartTrashBinServer.Repo
  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.TrashBinRepo
  alias SmartTrashBinServer.TrashCapacityHistory

  def latest_histories_query do
    min_time = Timex.now() |> Timex.shift(hours: -8)

    from history in TrashCapacityHistory,
      join: trash_bin in TrashBin,
      on: trash_bin.imsi == history.imsi,
      where: ^min_time < history.inserted_at,
      select: %{
        trash_bin_name: trash_bin.name,
        imsi: trash_bin.imsi,
        inserted_at: history.inserted_at,
        distance: history.distance
      }
  end

  def get_latest_histories do
    latest_histories_query() |> Repo.all()
  end

  def chart_datasets do
    labels = TrashBinRepo.fetch_trash_bin_labels()

    histories =
      get_latest_histories()
      |> Enum.group_by(fn history -> history.imsi end, fn history ->
        %{
          x: history.inserted_at,
          y: history.distance
        }
      end)

    labels
    |> Enum.map(fn {imsi, label} ->
      %{label: label, imsi: imsi, data: histories[imsi]}
    end)
  end
end
