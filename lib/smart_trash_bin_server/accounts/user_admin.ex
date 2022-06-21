defmodule SmartTrashBinServer.Accounts.UserAdmin do
  @moduledoc """
  Module for handling the user admin page
  """

  def widgets(_schema, _conn) do
    [
      %{
        type: "progress",
        title: "中央広場　燃えるゴミ箱 1",
        content: "ゴミの容量",
        percentage: 79,
        order: 3,
        width: 6
      },
      %{
        type: "progress",
        title: "中央広場　燃えるゴミ箱 2",
        content: "ゴミの容量",
        percentage: 40,
        order: 3,
        width: 6
      },
      %{
        type: "progress",
        title: "中央広場　燃えるゴミ箱 3",
        content: "ゴミの容量",
        percentage: 20,
        order: 3,
        width: 6
      },
      %{
        type: "progress",
        title: "千葉市動物公園森のレストラン 燃えるゴミ箱 1",
        content: "ゴミの容量",
        percentage: 93,
        order: 3,
        width: 6
      },
      %{
        type: "chart",
        title: "ゴミ量の変動",
        order: 8,
        width: 12,
        content: %{
          x: ["Mon", "Tue", "Wed", "Thu", "Today"],
          y: [30, 90, 39, 59, 82],
          y_title: "%"
        }
      }
    ]
  end

  def index(_) do
    [
      email: nil,
      inserted_at: nil,
      confirmed_at: nil
    ]
  end

  def form_fields(_) do
    [
      email: nil
    ]
  end
end
