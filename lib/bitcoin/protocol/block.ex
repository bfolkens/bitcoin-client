defmodule Bitcoin.Protocol.Block do
  alias Bitcoin.Protocol

  defstruct [:bits, :chainwork, :confirmations, :difficulty, :hash, :height, :mediantime, :merkleroot, :n_tx, :nonce, :previousblockhash, :size, :strippedsize, :time, :tx, :version, :version_hex, :weight]

  def from(data) when is_binary(data), do: data

  def from(data) when is_map(data) do
    %{
      bits: data["bits"],
      chainwork: data["chainwork"],
      confirmations: data["confirmations"],
      difficulty: data["difficulty"],
      hash: data["hash"],
      height: data["height"],
      mediantime: data["mediantime"],
      merkleroot: data["merkleroot"],
      n_tx: data["nTx"],
      nonce: data["nonce"],
      previousblockhash: data["previousblockhash"],
      size: data["size"],
      strippedsize: data["strippedsize"],
      time: data["time"],
      version: data["version"],
      version_hex: data["versionHex"],
      weight: data["weight"],
      tx: data["tx"] |> Enum.map(&Protocol.Transaction.from/1)
    }
  end

  def has_vout?(block, hash) do
    Enum.any?(block.tx, &Protocol.Transaction.has_vout?(&1, hash))
  end
end
