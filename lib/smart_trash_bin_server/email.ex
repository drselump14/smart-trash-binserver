defmodule SmartTrashBinServer.Email do
  @moduledoc """
  Email
  """
  use Bamboo.Phoenix, view: SmartTrashBinServerWeb.EmailView

  alias SmartTrashBinServer.TrashBin
  alias SmartTrashBinServer.TrashCapacityHistory

  @from "slamet.kristant@koshizuka-lab.org"
  @to [
    "dobutsu.zoo@city.chiba.lg.jp",
    "kyouryoku6617@wing.ocn.ne.jp",
    "slamet.kristant@koshizuka-lab.org"
  ]
  @subject "スマートごみ箱実証実験の自動通知"

  def notify_full_trash_bin(%TrashCapacityHistory{
        capacity_rate: capacity_rate,
        trash_bin: %TrashBin{name: trash_bin_name}
      }) do
    base_email()
    |> to(@to)
    |> subject(@subject)
    |> assign(:trash_bin_name, trash_bin_name)
    |> assign(:capacity_rate, capacity_rate)
    |> render("notify_full_trash_bin.text")
  end

  def notify_dead_trash_bin(trash_bins) do
    base_email()
    |> to("slamet.kristant@koshizuka-lab.org")
    |> subject("[電池ぎれ]" <> @subject)
    |> assign(:trash_bin_names, trash_bins |> Enum.map_join(& &1.name))
    |> render("notify_dead_trash_bin.text")
  end

  defp base_email do
    new_email()
    |> from(@from)
    |> put_text_layout({SmartTrashBinServerWeb.LayoutView, "email.text"})
  end
end
