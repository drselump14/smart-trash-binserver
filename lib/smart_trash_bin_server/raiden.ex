defmodule SmartTrashBinServer.Raiden do
  @moduledoc """
  Raiden API Wrapper
  """

  @ttt_token_address "0xC563388e2e2fdD422166eD5E76971D11eD37A466"

  def transfer(client, target_address, amount \\ 1, token_address \\ @ttt_token_address)
      when is_binary(target_address) and is_binary(token_address) do
    data = %{
      amount: amount
    }

    Tesla.post(client, "/api/v1/payments/" <> token_address <> "/" <> target_address, data)
  end

  @spec build_client(binary()) :: Tesla.Client.t()
  def build_client(raiden_node_url) do
    middleware = [
      {Tesla.Middleware.BaseUrl, raiden_node_url},
      Tesla.Middleware.JSON
    ]

    middleware |> Tesla.client()
  end
end
