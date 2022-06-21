defmodule SmartTrashBinServer.Operations.Payments.CreateOperation do
  @moduledoc """
  Operation module to handle raiden request
  """

  alias SmartTrashBinServer.Accounts.User
  alias SmartTrashBinServer.Raiden

  use TypedStruct

  typedstruct do
    @typedoc "Context"

    field :user, User, enforce: true
    field :target_address, binary(), enforce: true
    field :amount, integer(), default: 1
    field :raiden_node_url, binary()
    field :raiden_client, Tesla.Client.t()
    field :raiden_payment_response, map()
    field :payment_identifier, binary()
    field :success, boolean(), default: true
  end

  @spec call(%__MODULE__{}) :: {:ok, %__MODULE__{}} | {:error, %__MODULE__{}}
  def call(context) do
    context
    |> fetch_raiden_node_url()
    |> build_raiden_client()
    |> transfer()
    |> publish_open_bin_command()
    |> wrap_result()
  end

  @spec fetch_raiden_node_url(%__MODULE__{}) :: %__MODULE__{}
  def fetch_raiden_node_url(%__MODULE__{user: %User{raiden_node_url: raiden_node_url}} = context)
      when is_binary(raiden_node_url) do
    context
    |> Map.put(:raiden_node_url, raiden_node_url)
  end

  @spec build_raiden_client(%__MODULE__{}) :: %__MODULE__{}
  def build_raiden_client(%__MODULE__{raiden_node_url: raiden_node_url} = context)
      when is_binary(raiden_node_url) do
    raiden_client = raiden_node_url |> Raiden.build_client()

    context
    |> Map.put(:raiden_client, raiden_client)
  end

  @spec transfer(%__MODULE__{}) :: %__MODULE__{}
  def transfer(
        %__MODULE__{
          raiden_client: raiden_client,
          target_address: target_address,
          amount: amount
        } = context
      ) do
    case raiden_client |> Raiden.transfer(target_address, amount) do
      {:ok, %Tesla.Env{status: 200, body: %{"identifier" => payment_identifier} = body}} ->
        context
        |> Map.put(:raiden_payment_response, body)
        |> Map.put(:payment_identifier, payment_identifier)

      {:ok, %Tesla.Env{body: body}} ->
        context
        |> Map.put(:raiden_payment_response, body)
        |> Map.put(:success, false)

      _ ->
        context |> Map.put(:success, false)
    end
  end

  @spec publish_open_bin_command(%__MODULE__{}) :: %__MODULE__{}
  def publish_open_bin_command(%__MODULE__{success: true} = context) do
    case Tortoise.publish(SmartTrashBinServer, "kris-14/smart_trash_bin_node", "open") do
      :ok ->
        context

      _ ->
        context |> Map.put(:success, false)
    end
  end

  def publish_open_bin_command(%__MODULE__{success: false} = context), do: context

  def wrap_result(%__MODULE__{success: true} = context), do: {:ok, context}
  def wrap_result(%__MODULE__{success: false} = context), do: {:error, context}
end
