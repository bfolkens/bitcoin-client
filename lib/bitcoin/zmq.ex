defmodule Bitcoin.ZMQ do
  def zmq_url(), do: Application.get_env(:bitcoin, :zmq_url)

  def stream(socket) do
    Stream.resource(
      fn -> socket end,
      fn socket ->
        {:ok, data} = read(socket)
        {[decode(data)], socket}
      end,
      fn _socket -> :ok end
    )
  end

  def read(socket), do: :chumak.recv_multipart(socket)

  def connect(channels) do
    uri = URI.parse(zmq_url())
    connect(uri.host, uri.port, channels)
  end

  def connect(host, port, channel) when is_binary(channel), do:
    connect(host, port, [channel])

  def connect(host, port, channels) when is_list(channels) do
    {:ok, socket} = :chumak.socket(:sub)

    Enum.each(channels, fn channel -> :chumak.subscribe(socket, channel) end)

    {:ok, _bind_pid} = :chumak.connect(socket, :tcp, host |> to_charlist(), port)

    {:ok, socket}
  end

  def decode(["sequence", <<hash::size(32)-bytes, "C">>, <<seq::size(4)-unit(8)-unsigned-integer-little>>]) do
    txid = Base.encode16(hash, case: :lower)
    {:connected, txid, seq}
  end

  def decode(["sequence", <<hash::size(32)-bytes, "D">>, <<seq::size(4)-unit(8)-unsigned-integer-little>>]) do
    txid = Base.encode16(hash, case: :lower)
    {:disconnected, txid, seq}
  end

  def decode(["sequence", <<hash::size(32)-bytes, "R", mempool_seq::size(8)-unit(8)-unsigned-integer-little>>, <<seq::size(4)-unit(8)-unsigned-integer-little>>]) do
    txid = Base.encode16(hash, case: :lower)
    {:tx_removed, %{txid: txid, mempool_seq: mempool_seq}, seq}
  end

  def decode(["sequence", <<hash::size(32)-bytes, "A", mempool_seq::size(8)-unit(8)-unsigned-integer-little>>, <<seq::size(4)-unit(8)-unsigned-integer-little>>]) do
    txid = Base.encode16(hash, case: :lower)
    {:tx_added, %{txid: txid, mempool_seq: mempool_seq}, seq}
  end

  def decode(["rawtx", body, <<seq::size(4)-unit(8)-unsigned-integer-little>>]) do
    data = Base.encode16(body)
    {:rawtx, data, seq}
  end

  def decode(["hashblock", body, <<seq::size(4)-unit(8)-unsigned-integer-little>>]) do
    data = Base.encode16(body)
    {:hashblock, data, seq}
  end
end

