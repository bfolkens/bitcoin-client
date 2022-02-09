defmodule Bitcoin.Protocol.Transaction do
  alias Bitcoin.Protocol.{VIn, VOut}
  alias Bitcoin.Util

  defstruct [:txid, :hash, :locktime, :size, :version, :vin, :vout, :vsize, :weight]

  def from(txid) when is_binary(txid), do: txid
  def from(data) when is_map(data) do
    %{
      txid: data["txid"],
      hash: data["hash"],
      locktime: data["locktime"],
      size: data["size"],
      version: data["version"],
      vsize: data["vsize"],
      weight: data["weight"],
      vin: data["vin"] |> Enum.map(&VIn.from/1),
      vout: data["vout"] |> Enum.map(&VOut.from/1)
    }
    |> Util.maybe_put(:fee, data["fee"], &Decimal.from_float/1)
  end

  def has_vout?(tx, hash) do
    Enum.any?(tx.vout, fn vout -> vout.script_pub_key.address == hash end)
  end

  def vout_with_address(tx, hash) do
    Enum.filter(tx.vout, fn vout -> vout.script_pub_key.address == hash end)
  end

  def balance_for_address(tx, address) do
    vout = vout_with_address(tx, address)

    if vout != [] do
      Enum.reduce(vout, Decimal.new(0), &Decimal.add(&1.value, &2))
    else
      nil
    end
  end
end

defmodule Bitcoin.Protocol.VIn do
  alias Bitcoin.Protocol.ScriptSig
  alias Bitcoin.Util

  defstruct [:script_sig, :sequence, :txid, :txinwitness, :vout, :coinbase]

  def from(data) when is_map(data) do
    %{
      sequence: data["sequence"],
      txinwitness: data["txinwitness"]
    }
    |> Util.maybe_put(:script_sig, data["scriptSig"], &ScriptSig.from/1)
    |> Util.maybe_put(:coinbase, data["coinbase"])
    |> Util.maybe_put(:txid, data["txid"])
    |> Util.maybe_put(:vout, data["vout"])
  end
end

defmodule Bitcoin.Protocol.VOut do
  alias Bitcoin.Protocol.ScriptPubKey

  defstruct [:n, :script_pub_key, :value]

  def from(data) when is_map(data) do
    %{
      n: data["n"],
      script_pub_key: ScriptPubKey.from(data["scriptPubKey"]),
      value: Decimal.from_float(data["value"])
    }
  end
end

defmodule Bitcoin.Protocol.ScriptSig do
  defstruct [:asm, :hex]

  def from(data) when is_map(data) do
    %{
      asm: data["asm"],
      hex: data["hex"]
    }
  end
end

defmodule Bitcoin.Protocol.ScriptPubKey do
  defstruct [:address, :asm, :hex, :type]

  def from(data) when is_map(data) do
    %{
      asm: data["asm"],
      hex: data["hex"],
      address: data["address"],
      type: data["type"]
    }
  end
end

