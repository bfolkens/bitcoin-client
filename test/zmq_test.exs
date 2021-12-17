defmodule Bitcoin.ZMQTest do
  use ExUnit.Case, async: false
  alias Bitcoin.{Client, ZMQ}

  setup_all do
    {:ok, address} = Client.getnewaddress()
    {:ok, %{address: address}}
  end

  test "should receive hashblock", %{address: address} do
    {:ok, socket} = ZMQ.connect(["hashblock"])

    parent = self()
    Task.async(fn ->
      [data] =
        ZMQ.stream(socket)
        |> Enum.take(1)

      send(parent, data)
    end)

    Process.sleep(250)

    {:ok, [expected_hash]} = Client.generatetoaddress(1, address)
    assert_receive {:hashblock, hashblock, _seq}, 250

    {:ok, block} = Bitcoin.Client.getblock(hashblock, verbosity: 1)
    assert expected_hash == block.hash
  end

  test "should receive rawtx", %{address: address} do
    {:ok, socket} = ZMQ.connect(["rawtx"])

    parent = self()
    Task.async(fn ->
      [data] =
        ZMQ.stream(socket)
        |> Enum.take(1)

      send(parent, data)
    end)

    Process.sleep(250)

    {:ok, _} = Client.generatetoaddress(1, address)
    assert_receive {:rawtx, _data, _seq}, 250
  end
end
