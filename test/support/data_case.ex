defmodule SmartTrashBinServer.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use SmartTrashBinServer.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.Factory
  use ExUnit.CaseTemplate

  using do
    quote do
      alias SmartTrashBinServer.Repo
      alias SmartTrashBinServer.Factory

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import SmartTrashBinServer.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SmartTrashBinServer.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SmartTrashBinServer.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def setup_trash_bin(_context) do
    trash_bin = Factory.insert(:trash_bin)

    %{trash_bin: trash_bin}
  end

  def setup_empty_trash_capacity_history(%{trash_bin: trash_bin}) do
    %TrashBin{
      empty_distance: empty_distance,
      sensor_and_bucket_distance: sensor_and_bucket_distance
    } = trash_bin

    trash_bin |> insert_trash_capacity_history(sensor_and_bucket_distance + empty_distance)
  end

  def setup_full_trash_capacity_history(%{trash_bin: trash_bin}) do
    %TrashBin{
      sensor_and_bucket_distance: sensor_and_bucket_distance
    } = trash_bin

    trash_bin |> insert_trash_capacity_history(sensor_and_bucket_distance)
  end

  def setup_invalid_trash_capacity_history(%{trash_bin: trash_bin}) do
    invalid_value = Faker.random_between(7_000, 10_000)
    trash_bin |> insert_trash_capacity_history(invalid_value)
  end

  def insert_trash_capacity_history(%TrashBin{} = trash_bin, distance) do
    capacity =
      :trash_capacity_history |> Factory.insert(%{trash_bin: trash_bin, distance: distance})

    %{trash_bin: trash_bin, capacity: capacity}
  end
end
