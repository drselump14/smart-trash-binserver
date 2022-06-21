defmodule SmartTrashBinServer.CheckDeadNodeWorkerTest do
  @moduledoc """
  Test module for CheckDeadNodeWorker
  """
  use SmartTrashBinServer.DataCase

  alias SmartTrashBinServer.CheckDeadNodeWorker
  alias SmartTrashBinServer.TrashBin

  describe "perform" do
    setup [
      :setup_trash_bin,
      :setup_full_trash_capacity_history
    ]

    test "perform", %{trash_bin: trash_bin_with_capacity_history} do
      trash_bin_with_no_capacity_history = Factory.insert(:trash_bin)
      assert :ok = %Oban.Job{} |> CheckDeadNodeWorker.perform()

      assert %TrashBin{dead: true} = TrashBin |> Repo.get(trash_bin_with_no_capacity_history.id)
      assert %TrashBin{dead: false} = TrashBin |> Repo.get(trash_bin_with_capacity_history.id)
    end
  end
end
