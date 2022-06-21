# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SmartTrashBinServer.Repo.insert!(%SmartTrashBinServer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias SmartTrashBinServer.Accounts
alias SmartTrashBinServer.TrashBinRepo

%{
  email: "slamet.kristant@koshizuka-lab.org",
  password: System.get_env("ADMIN_PASSWORD"),
  firstname: "Slamet",
  lastname: "Kristanto"
}
|> Accounts.seed_user()

%{
  email: "jikken@chiba-zoo.org",
  password: System.get_env("ADMIN_PASSWORD"),
  firstname: "Chiba",
  lastname: "Zoo"
}
|> Accounts.seed_user()

if Mix.env() == :dev do
  %{
    sim_id: "8981100005821765345",
    imsi: "440103228759761",
    name: "test stb",
    left: 440,
    top: 217,
    empty_distance: 700,
    sensor_and_bucket_distance: 430,
    location: %Geo.Point{coordinates: {35.644773, 140.126910}}
  }
  |> TrashBinRepo.upsert_with_sim_id()

  TrashBinRepo.upsert_with_sim_id(%{
    sim_id: "sim_id",
    imsi: "imsi",
    name: "test stb imsi",
    left: 340,
    top: 240,
    empty_distance: 700,
    sensor_and_bucket_distance: 430,
    location: %Geo.Point{coordinates: {35.644773, 140.126910}}
  })
end

if Mix.env() == :prod do
  TrashBinRepo.upsert_with_sim_id(%{
    sim_id: "8981100005821487262",
    imsi: "440103256330588",
    name: "1) 食堂前の可燃ゴミ箱",
    left: 440,
    top: 217,
    empty_distance: 700,
    sensor_and_bucket_distance: 430,
    location: %Geo.Point{coordinates: {35.644773, 140.126910}}
  })

  TrashBinRepo.upsert_with_sim_id(%{
    sim_id: "8981100005821487254",
    imsi: "440103256125480",
    name: "2) 中央広場可燃ゴミ箱",
    left: 340,
    top: 240,
    empty_distance: 700,
    sensor_and_bucket_distance: 430,
    location: %Geo.Point{coordinates: {35.644783, 140.127920}}
  })

  TrashBinRepo.upsert_with_sim_id(%{
    sim_id: "8981100005821487247",
    imsi: "440103256328583",
    name: "3) 展望デッキ可燃ゴミ",
    left: 230,
    top: 270,
    empty_distance: 700,
    sensor_and_bucket_distance: 430,
    location: %Geo.Point{coordinates: {35.644783, 140.127920}}
  })
end
