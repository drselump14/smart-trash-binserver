defmodule SmartTrashBinServer.CollectAndNotifyDeadNodesOperation do
  @moduledoc """
  Collect dead nodes and notify
  """

  alias SmartTrashBinServer.Email
  alias SmartTrashBinServer.Mailer
  alias SmartTrashBinServer.Repo
  alias SmartTrashBinServer.TrashBinRepo

  def call do
    dead_nodes = TrashBinRepo.dead_trash_bins_query() |> Repo.all()

    dead_nodes
    |> Enum.map(& &1.id)
    |> TrashBinRepo.update_dead_node_status()

    dead_nodes
    |> send_email()
  end

  def send_email([] = dead_nodes), do: dead_nodes

  def send_email(dead_nodes) do
    dead_nodes
    |> Email.notify_dead_trash_bin()
    |> Mailer.deliver_now!()
  end
end
