defmodule SmartTrashBinServerWeb.SoracomAuthPlug do
  @moduledoc """
  Authenticate coming request from soracom-beam

  see: https://developers.soracom.io/en/docs/beam/signature-verification/
  """

  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    imei = conn |> get_req_header("x-soracom-imei") |> Enum.at(0)
    imsi = conn |> get_req_header("x-soracom-imsi") |> Enum.at(0)
    msisdn = conn |> get_req_header("x-soracom-msisdn") |> Enum.at(0)
    sim_id = conn |> get_req_header("x-soracom-sim-id") |> Enum.at(0)
    timestamp = conn |> get_req_header("x-soracom-timestamp") |> Enum.at(0)
    signature = conn |> get_req_header("x-soracom-signature") |> Enum.at(0)

    concat_raw_signature =
      "#{pre_shared_key()}x-soracom-imei=#{imei}x-soracom-imsi=#{imsi}x-soracom-msisdn=#{msisdn}x-soracom-sim-id=#{sim_id}x-soracom-timestamp=#{timestamp}"

    calculated_signature =
      :sha256 |> :crypto.hash(concat_raw_signature) |> Base.encode16() |> String.downcase()

    Logger.info("imei: #{imei}")
    Logger.info("imsi: #{imsi}")
    Logger.info("msisdn: #{msisdn}")
    Logger.info("sim_id: #{sim_id}")
    Logger.info("timestamp: #{timestamp}")
    Logger.info("signature: #{signature}")
    Logger.info("calculated_signature #{calculated_signature}")

    if signature == calculated_signature do
      conn
      |> assign(:sim_id, sim_id)
      |> assign(:imsi, imsi)
    else
      conn
      |> send_resp(:unauthorized, "Unauthorized")
      |> halt()
    end
  end

  @spec pre_shared_key() :: binary()
  def pre_shared_key do
    soracom_env()[:pre_shared_key]
  end

  def soracom_env do
    Application.get_env(:smart_trash_bin_server, :soracom)
  end
end
