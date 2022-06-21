defmodule SmartTrashBinServer.CheckDeadNodeWorker do
  @moduledoc """
  Worker to check dead trash bin node
  """

  use Oban.Worker, queue: :events

  alias SmartTrashBinServer.CollectAndNotifyDeadNodesOperation

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Update dead node status")
    CollectAndNotifyDeadNodesOperation.call()
    :ok
  end
end
