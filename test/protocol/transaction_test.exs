defmodule Bitcoin.Protocol.TransactionTest do
  use ExUnit.Case
  alias Bitcoin.Protocol

  @tx %Protocol.Transaction{
    vout: [
      %Protocol.VOut{
        script_pub_key: %Protocol.ScriptPubKey{
          address: "abbacadabba"
        }
      }
    ]
  }

  test "has_vout?/1 checks for address" do
    refute Protocol.Transaction.has_vout?(@tx, "bogus")
    assert Protocol.Transaction.has_vout?(@tx, "abbacadabba")
  end

  test "vout_with_address/1 filters tx for address" do
    assert Protocol.Transaction.vout_with_address(@tx, "bogus") == []
    assert Protocol.Transaction.vout_with_address(@tx, "abbacadabba") == @tx.vout
  end
end
