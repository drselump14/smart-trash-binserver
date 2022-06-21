defmodule SmartTrashBinServer.TrashCapacityPubSub do
  @moduledoc """
  Pubsub for update trash_level information
  """

  alias SmartTrashBinServer.TrashCapacityHistory

  require Logger

  @topic inspect(__MODULE__)

  def subscribe do
    SmartTrashBinServer.PubSub
    |> Phoenix.PubSub.subscribe(@topic)
  end

  def notify_subscriber({:ok, %TrashCapacityHistory{} = capacity}, event) do
    SmartTrashBinServer.PubSub
    |> Phoenix.PubSub.broadcast(@topic, {event, capacity})

    {:ok, capacity}
  end

  def notify_subscriber({:error, reason}, _), do: {:error, reason}
end
