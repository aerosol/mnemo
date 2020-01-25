defmodule Mnemo do
  def generate(strength \\ 128) when strength in [128, 160, 192, 224, 256] do
    strength
    |> div(8)
    |> :crypto.strong_rand_bytes()
    |> mnemonic()
  end

  def mnemonic(entropy) do
    entropy
    |> decode()
    |> assert_size()
    |> update_with_checksum()
    |> sentence()
    |> Enum.map(&word/1)
    |> Enum.join(" ")
  end

  def decode(ent) do
    case Base.decode16(ent, case: :mixed) do
      :error -> ent
      {:ok, decoded} -> decoded
    end
  end

  def assert_size(ent) when bit_size(ent) >= 128 and bit_size(ent) <= 256, do: ent
  def assert_size(_ent), do: raise("ENT must be 128-256 bits")

  def update_with_checksum(ent) do
    {checksum, checksum_size} = checksum(ent)
    <<ent::binary, checksum::size(checksum_size)>>
  end

  def sentence(ent_cs), do: chunks(ent_cs, 11)

  def chunks(binary, n) do
    do_chunks(binary, n, [])
  end

  def decode_integer(b) when is_bitstring(b) do
    b
    |> pad_leading_zeros()
    |> :binary.decode_unsigned(:big)
  end

  def word(i, lang \\ :english) when i in 0..2047 do
    "priv/#{lang}.txt"
    |> File.stream!()
    |> Stream.with_index()
    |> Stream.filter(fn {_value, index} -> index == i end)
    |> Enum.at(0)
    |> elem(0)
    |> String.trim()
  end

  def checksum(ent) do
    s = div(bit_size(ent), 32)
    {part(:crypto.hash(:sha256, ent), s), s}
  end

  def pad_leading_zeros(bs) when is_binary(bs), do: bs

  def pad_leading_zeros(bs) when is_bitstring(bs) do
    pad_length = 8 - rem(bit_size(bs), 8)
    <<0::size(pad_length), bs::bitstring>>
  end

  defp do_chunks(binary, n, acc) when bit_size(binary) <= n do
    Enum.reverse([decode_integer(<<binary::bitstring>>) | acc])
  end

  defp do_chunks(binary, n, acc) do
    <<chunk::size(n), rest::bitstring>> = binary
    do_chunks(rest, n, [decode_integer(<<chunk::size(n)>>) | acc])
  end

  defp part(bin, n) do
    <<x::integer-size(n), _t::bitstring>> = bin
    x
  end
end
