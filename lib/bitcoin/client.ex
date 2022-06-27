defmodule Bitcoin.Client do
  alias Bitcoin.{Request, Protocol}

  def getbalance() do
    Request.send("getbalance")
  end

  def getwalletinfo() do
    Request.send("getwalletinfo")
  end

  def getnetworkinfo() do
    Request.send("getnetworkinfo")
  end

  def getblockcount() do
    Request.send("getblockcount")
  end

  def gettxout(txid, vout_number, opts \\ []) do
    Request.send("gettxout", [txid, vout_number, opts[:include_mempool]])
  end

  def getmempoolinfo() do
    Request.send("getmempoolinfo")
  end

  def getrawmempool(opts \\ []) do
    Request.send("getrawmempool", [opts[:verbose], opts[:mempool_sequence]])
  end

  def getblockchaininfo() do
    Request.send("getblockchaininfo", [])
  end

  def getblock(blockhash, opts \\ []) do
    with {:ok, response} <- Request.send("getblock", [blockhash, opts[:verbosity]]) do
      {:ok, Protocol.Block.from(response)}
    end
  end

  def getblockheader(blockhash) do
    Request.send("getblockheader", [blockhash])
  end

  def getnewaddress() do
    Request.send("getnewaddress", [])
  end

  def getaddressinfo(address) do
    Request.send("getaddressinfo", [address])
  end

  def listtransactions(), do: Request.send("listtransactions", [])
  def listtransactions(label), do: Request.send("listtransactions", [label])

  def listsinceblock(), do: Request.send("listsinceblock", [])
  def listsinceblock(blockhash), do: Request.send("listsinceblock", [blockhash])

  def createwallet(wallet_name, opts \\ []) do
    Request.send("createwallet", [
      wallet_name,
      opts[:disable_private_keys],
      opts[:blank],
      opts[:passphrase],
      opts[:avoid_reuse],
      opts[:descriptors],
      opts[:load_on_startup]
    ])
  end

  def gettransaction(txid) do
    Request.send("gettransaction", [txid])
  end

  def loadwallet(filename, opts \\ []) do
    Request.send("loadwallet", [filename, opts[:load_on_startup]])
  end

  def unloadwallet(opts \\ []) do
    Request.send("unloadwallet", [opts[:wallet_name], opts[:load_on_startup]])
  end

  def listdescriptors() do
    Request.send("listdescriptors", [])
  end

  def importdescriptors(desc) do
    Request.send("importdescriptors", [desc])
  end

  def getdescriptorinfo(desc) do
    Request.send("getdescriptorinfo", [desc])
  end

  def generatetoaddress(num_blocks, address) do
    Request.send("generatetoaddress", [num_blocks, address])
  end

  def sendtoaddress(address, amount, _opts \\ []) do
    Request.send("sendtoaddress", [address, amount])
  end

  def decodescript(script) do
    Request.send("decodescript", [script])
  end

  def walletcreatefundedpsbt(inputs, outputs, opts \\ []) do
    Request.send("walletcreatefundedpsbt", [inputs, outputs, opts[:locktime], opts[:options], opts[:bip32derivs]])
  end

  def walletprocesspsbt(psbt, opts \\ []) do
    Request.send("walletprocesspsbt", [psbt, opts[:sign], opts[:sighashtype], opts[:bip32derivs], opts[:finalize]])
  end

  def decodepsbt(psbt) do
    Request.send("decodepsbt", [psbt])
  end

  def analyzepsbt(psbt) do
    Request.send("analyzepsbt", [psbt])
  end

  def combinepsbt(psbts) do
    Request.send("combinepsbt", [psbts])
  end

  def finalizepsbt(psbt_hex) do
    Request.send("finalizepsbt", [psbt_hex])
  end

  def sendrawtransaction(hexstring) do
    Request.send("sendrawtransaction", [hexstring])
  end

  def decoderawtransaction(hexstring) do
    with {:ok, response} <- Request.send("decoderawtransaction", [hexstring]) do
      {:ok, Protocol.Transaction.from(response)}
    end
  end
end
