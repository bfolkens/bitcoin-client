defmodule Bitcoin.Util do
  @sats_per_btc :math.pow(10, 8)

  def btc_to_decimal(value) when is_float(value) do
    sats = round(value * @sats_per_btc)
    %Decimal{sign: if(sats < 0, do: -1, else: 1), coef: abs(sats), exp: -8}
  end

  def btc_to_decimal(nil), do: nil

  def maybe_put(map, key, value, process_fun \\ nil)
  def maybe_put(map, _key, nil, _process_fun), do: map
  def maybe_put(map, key, value, nil), do: Map.put(map, key, value)
  def maybe_put(map, key, value, process_fun), do: Map.put(map, key, process_fun.(value))
end
