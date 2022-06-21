defmodule SmartTrashBinServer.RaidenLive do
  @moduledoc """
  Raiden Live Page
  """

  use SmartTrashBinServerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "")}
  end

  @impl true
  def handle_event("pay", %{}, socket) do
    {:noreply, assign(socket, query: %{})}
  end
end
