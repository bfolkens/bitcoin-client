defmodule Bitcoin.Request do
  def child_spec do
    {
      Finch,
      name: __MODULE__,
      pools: %{
        :default => [size: pool_size()]
      }
    }
  end

  def pool_size, do: Application.get_env(:bitcoin, :pool_size)

  def rpc_url, do: Application.get_env(:bitcoin, :rpc_url)

  def rpc_user, do: Application.get_env(:bitcoin, :rpc_user)

  def rpc_password, do: Application.get_env(:bitcoin, :rpc_password)

  def rpc_wallet, do: Application.get_env(:bitcoin, :rpc_wallet)

  def send(command, params \\ []) do
    url = rpc_url() <> "/wallet/" <> rpc_wallet()

    body = Jason.encode!(%{jsonrpc: "2.0", method: command, params: params})

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic #{authorization()}"}
    ]

    Finch.build(:post, url, headers, body)
    |> Finch.request(__MODULE__)
    |> handle_response()
  end

  def handle_response({:ok, %{body: body, status: code}}) do
    case Jason.decode(body) do
      {:ok, %{"error" => nil, "result" => result}} ->
        {:ok, result}

      {:ok, %{"error" => error}} ->
        {:error, error}

      {:error, _error} ->
        {:error, "Process returned (#{code}): #{body}"}
    end
  end

  def handle_response({:error, reason}), do: {:error, reason}

  defp authorization do
    [rpc_user(), rpc_password()]
    |> Enum.join(":")
    |> Base.encode64()
  end
end
