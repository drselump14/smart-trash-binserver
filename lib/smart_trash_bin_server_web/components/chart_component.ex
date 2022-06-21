defmodule SmartTrashBinServerWeb.ChartComponent do
  @moduledoc """
  Component to render chart
  """

  use Surface.Component

  prop imsi, :string, required: true
  prop dataset, :map, required: true

  def render(assigns) do
    ~F"""
      <div>
        <canvas
          id={ "chart-canvas-" <> @imsi }
          data-imsi={@imsi}
          data-chart-dataset={[@dataset] |> Jason.encode!}
          phx-update="ignore"
          phx-hook="LineChart">
        </canvas>
      </div>
    """
  end
end
