defmodule SmartTrashBinServerWeb.PaymentsController do
  use SmartTrashBinServerWeb, :controller

  alias SmartTrashBinServer.Operations.Payments.CreateOperation

  require Logger

  @spec create(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def create(
        %{assigns: %{current_user: current_user}} = conn,
        %{"target_address" => target_address, "amount" => amount} = _params
      ) do
    context = %CreateOperation{
      user: current_user,
      target_address: target_address,
      amount: amount
    }

    case context |> CreateOperation.call() do
      {:ok, _} ->
        conn
        |> render(:success, target_address: target_address, amount: amount)

      {:error, context} ->
        Logger.info(context)
        conn |> send_resp(400, "")
    end
  end

  def create(conn, _params) do
    conn |> send_resp(:bad_request, "target_address and amount are required")
  end

  @spec confirmation(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def confirmation(conn, %{"target_address" => target_address}) do
    render(conn, :confirmation, target_address: target_address, amount: 1)
  end

  def confirmation(conn, _params) do
    conn |> send_resp(:not_found, "")
  end
end
