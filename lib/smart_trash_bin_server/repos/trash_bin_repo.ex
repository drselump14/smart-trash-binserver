defmodule SmartTrashBinServer.TrashBinRepo do
  @moduledoc """
  Repo for TrashBin
  """

  import Ecto.Query, warn: false
  alias SmartTrashBinServer.Repo
  import Torch.Helpers, only: [sort: 1, paginate: 4, strip_unset_booleans: 3]
  import Filtrex.Type.Config

  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.TrashCapacityHistory

  @pagination_distance 5
  @pagination [page_size: 15]

  def marker_datasets do
    TrashBin
    |> Repo.all()
    |> Repo.preload(
      latest_capacity_history: from(h in TrashCapacityHistory, order_by: [desc: :id])
    )
    |> Enum.map(fn %TrashBin{
                     name: name,
                     left: left,
                     top: top,
                     imsi: imsi,
                     empty_distance: empty_distance,
                     sensor_and_bucket_distance: sensor_and_bucket_distance,
                     latest_capacity_history: history
                   } ->
      distance = history |> fetch_distance()

      %{
        imsi: imsi,
        left: left,
        top: top,
        label: name,
        capacity_rate:
          distance
          |> TrashCapacityHistory.calc_capacity_rate(empty_distance, sensor_and_bucket_distance),
        distance: distance
      }
    end)
  end

  def fetch_trash_bin_labels do
    query =
      from trash_bin in TrashBin,
        select: %{
          label: trash_bin.name,
          imsi: trash_bin.imsi
        }

    query
    |> Repo.all()
    |> Enum.into(%{}, fn %{imsi: imsi, label: label} ->
      {imsi, label}
    end)
  end

  defp fetch_distance(%TrashCapacityHistory{distance: distance}), do: distance
  defp fetch_distance(nil), do: nil

  @doc """
  Paginate the list of trash_bins using filtrex
  filters.


  ## Examples

      iex> paginate_trash_bins(%{})
      %{trash_bins: [%TrashBin{}], ...}

  """
  @spec paginate_trash_bins(map) :: {:ok, map} | {:error, any}
  def paginate_trash_bins(params \\ %{}) do
    params =
      params
      |> strip_unset_booleans("trash_bin", [])
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:trash_bins), params["trash_bin"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_trash_bins(filter, params) do
      {:ok,
       %{
         trash_bins: page.entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_trash_bins(filter, params) do
    from(t in TrashBin)
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of trash_bins.

  ## Examples

      iex> list_trash_bins()
      [%TrashBin{}, ...]

  """
  def list_trash_bins do
    Repo.all(TrashBin)
  end

  @doc """
  Gets a single trash_bin.

  Raises `Ecto.NoResultsError` if the Trash bin does not exist.

  ## Examples

      iex> get_trash_bin!(123)
      %TrashBin{}

      iex> get_trash_bin!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trash_bin!(id), do: Repo.get!(TrashBin, id)

  @doc """
  Creates a trash_bin.

  ## Examples

      iex> create_trash_bin(%{field: value})
      {:ok, %TrashBin{}}

      iex> create_trash_bin(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trash_bin(attrs \\ %{}) do
    %TrashBin{}
    |> TrashBin.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trash_bin.

  ## Examples

      iex> update_trash_bin(trash_bin, %{field: new_value})
      {:ok, %TrashBin{}}

      iex> update_trash_bin(trash_bin, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trash_bin(%TrashBin{} = trash_bin, attrs) do
    trash_bin
    |> TrashBin.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TrashBin.

  ## Examples

      iex> delete_trash_bin(trash_bin)
      {:ok, %TrashBin{}}

      iex> delete_trash_bin(trash_bin)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trash_bin(%TrashBin{} = trash_bin) do
    Repo.delete(trash_bin)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trash_bin changes.

  ## Examples

      iex> change_trash_bin(trash_bin)
      %Ecto.Changeset{source: %TrashBin{}}

  """
  def change_trash_bin(%TrashBin{} = trash_bin, attrs \\ %{}) do
    TrashBin.changeset(trash_bin, attrs)
  end

  def upsert_with_sim_id(%{sim_id: _sim_id} = attrs) do
    %TrashBin{}
    |> TrashBin.changeset(attrs)
    |> Repo.insert!(on_conflict: :replace_all, conflict_target: :sim_id)
  end

  def filter_config(:trash_bins) do
    defconfig do
      text(:sim_id)
      text(:imsi)
      text(:name)
      number(:empty_distance)
      number(:sensor_and_bucket_distance)
      number(:left)
      number(:top)
      text(:description)
      boolean(:dead)
    end
  end

  def dead_trash_bins_query do
    two_hours_ago = Timex.now() |> Timex.shift(hours: -2)

    from t in TrashBin,
      left_join: h in TrashCapacityHistory,
      on: h.imsi == t.imsi and h.inserted_at > ^two_hours_ago,
      where: h.id |> is_nil()
  end

  def update_dead_node_status(dead_node_ids) do
    from(t in TrashBin, where: t.id in ^dead_node_ids)
    |> Repo.update_all(set: [dead: true])
  end
end
