defmodule Bitcoin.Protocol.TransactionTest do
  use ExUnit.Case
  alias Bitcoin.Protocol

  @tx %Protocol.Transaction{
    vout: [
      %Protocol.VOut{
        script_pub_key: %Protocol.ScriptPubKey{
          address: "abbacadabba"
        },
        value: Decimal.from_float(50.0)
      }
    ]
  }

  test "has_vout?/2 checks for address" do
    refute Protocol.Transaction.has_vout?(@tx, "bogus")
    assert Protocol.Transaction.has_vout?(@tx, "abbacadabba")
  end

  test "vout_with_address/2 filters tx for address" do
    assert Protocol.Transaction.vout_with_address(@tx, "bogus") == []
    assert Protocol.Transaction.vout_with_address(@tx, "abbacadabba") == @tx.vout
  end

  test "balance_for_address/2 filters tx for address" do
    assert is_nil(Protocol.Transaction.balance_for_address(@tx, "bogus"))
    assert Protocol.Transaction.balance_for_address(@tx, "abbacadabba") == Decimal.from_float(50.0)
  end
end
