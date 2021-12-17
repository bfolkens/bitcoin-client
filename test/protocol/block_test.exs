defmodule Bitcoin.Protocol.BlockTest do
  use ExUnit.Case
  alias Bitcoin.Protocol

  @block %Protocol.Block{
    tx: [
      %Protocol.Transaction{
        vout: [
          %Protocol.VOut{
            script_pub_key: %Protocol.ScriptPubKey{
              address: "abbacadabba"
            }
          }
        ]
      }
    ]
  }

  test "has_vout?/1 checks for address" do
    refute Protocol.Block.has_vout?(@block, "bogus")
    assert Protocol.Block.has_vout?(@block, "abbacadabba")
  end
end

