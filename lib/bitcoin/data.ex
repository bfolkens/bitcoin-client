defmodule Bitcoin.Data do
  # https://en.bitcoin.it/wiki/Protocol_documentation#block

  def decoderawblock(<<header::binary-size(80), data::binary>>) do
    header = decodeblockheader(header)
    {items, _data} = decodevarstream(data, &decodetx/1)

    %{header: header, items: items}
  end

  def decodeblockheader(<<version::size(4)-unit(8)-signed-integer-little, prev_hash::bytes-size(32), merkle_root::bytes-size(32), timestamp::size(4)-unit(8)-unsigned-integer-little, bits::size(4)-unit(8)-unsigned-integer-little, nonce::size(4)-unit(8)-unsigned-integer-little>>) do
    %{
      version: version |> Integer.to_string(16),
      prev_hash: prev_hash |> Base.encode64(),
      merkle_root: merkle_root |> Base.encode64(),
      timestamp: timestamp,
      bits: bits |> Integer.to_string(16),
      nonce: nonce |> Integer.to_string(16)
    }
  end

  def decodevarint(<<0xFF, txn_count::size(8)-unit(8)-unsigned-integer-native, data::binary>>), do: {txn_count, data}
  def decodevarint(<<0xFE, txn_count::size(4)-unit(8)-unsigned-integer-little, data::binary>>), do: {txn_count, data}
  def decodevarint(<<0xFD, txn_count::size(2)-unit(8)-unsigned-integer-little, data::binary>>), do: {txn_count, data}
  def decodevarint(<<txn_count::size(1)-unit(8)-unsigned-integer-little, data::binary>>), do: {txn_count, data}

  def decodevarstream(data, parser) do
    {count, data} = decodevarint(data)
    decodevarstream(data, parser, count, [])
  end

  def decodevarstream(data, _parser, 0, items), do: {items |> Enum.reverse(), data}

  def decodevarstream(data, parser, count, items) do
    {item, data} = parser.(data)
    decodevarstream(data, parser, count - 1, [item | items])
  end

  def decodevarchar(data) do
    {len, data} = decodevarint(data)

    if len > 0 do
      <<str::size(len)-binary, data::binary>> = data
      {str, data}
    else
      {nil, data}
    end
  end

  def decodetx(<<version::size(4)-unit(8)-unsigned-integer-little, <<0x00, 0x01>>, data::binary>>) do
    {txins, data} = decodevarstream(data, &decodetxin/1)
    {txouts, data} = decodevarstream(data, &decodetxout/1)
    {witnesses, data} = decodevarstream(data, &decodevarchar/1, length(txins), [])

    <<lock_time::size(4)-unit(8)-unsigned-integer-little, data::binary>> = data

    {%{version: version, txins: txins, txouts: txouts, witnesses: witnesses, lock_time: lock_time}, data}
    |> IO.inspect()
  end

  def decodetx(<<version::size(4)-unit(8)-unsigned-integer-little, data::binary>>) do
    {txins, data} = decodevarstream(data, &decodetxin/1)
    {txouts, data} = decodevarstream(data, &decodetxout/1)

    <<lock_time::size(4)-unit(8)-unsigned-integer-little, data::binary>> = data

    {%{version: version, txins: txins, txouts: txouts, lock_time: lock_time}, data}
    |> IO.inspect()
  end

  def decodetxin(<<prev_out::bytes-size(36), data::binary>>) do
    prev_out = decodeoutpoint(prev_out)

    {script_length, data} = decodevarint(data)
    <<script::size(script_length)-binary,
      sequence::size(4)-unit(8)-unsigned-integer-little,
      data::binary>> = data

    {%{previous_output: prev_out, script: script, sequence: sequence |> Integer.to_string(16)}, data}
  end

  def decodetxout(<<value::size(8)-unit(8)-integer-little, data::binary>>) do
    {pk_script, data} = decodevarchar(data)

    {%{value: value, pk_script: pk_script}, data}
  end

  def decodeoutpoint(<<hash::binary-size(32), index::size(4)-unit(8)-unsigned-integer-little>>) do
    %{hash: hash, index: index}
  end
end

# {:ok, rawblock} = Bitcoin.Request.send("getblock", ["00000000000000000009b64d24e7ccbe95596c6b2de0bb598fba8cd3dcd4f0c9", 0])
# Bitcoin.ZMQ.decoderawblock(rawblock |> Base.decode16!(case: :lower))

