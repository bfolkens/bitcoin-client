defmodule Bitcoin.Client do
  alias Bitcoin.{Request, Protocol}

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

  def createwallet(name) do
    Request.send("createwallet", [name])
  end

  def loadwallet(name) do
    Request.send("loadwallet", [name])
  end

  def generatetoaddress(num_blocks, address) do
    Request.send("generatetoaddress", [num_blocks, address])
  end

  def sendtoaddress(address, amount, _opts \\ []) do
    Request.send("sendtoaddress", [address, amount])
  end

  def decoderawtransaction(hexstring) do
    with {:ok, response} <- Request.send("decoderawtransaction", [hexstring]) do
      {:ok, Protocol.Transaction.from(response)}
    end
  end
end
