ExUnit.start()

# Setup Bitcoin
case Bitcoin.Client.createwallet("test") do
  {:ok, _} ->
    {:ok, address} = Bitcoin.Client.getnewaddress()
    {:ok, _} = Bitcoin.Client.generatetoaddress(101, address)

  {:error, _} ->
    # There's already a wallet created
    :ok
end

