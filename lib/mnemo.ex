defmodule Mnemo do
  @valid_strenghts [128, 160, 192, 224, 256]
  @default_strength 256
  @valid_mnemonic_word_count [12, 15, 18, 21, 24]

  def generate(strength \\ @default_strength) when strength in @valid_strenghts do
    strength
    |> div(8)
    |> :crypto.strong_rand_bytes()
    |> mnemonic()
  end

  def mnemonic(entropy) do
    entropy
    |> maybe_decode()
    |> update_with_checksum()
    |> sentence()
    |> Enum.map(&word/1)
    |> Enum.join(" ")
  end

  def entropy(mnemonic) do
    words = String.split(mnemonic)

    if length(words) not in @valid_mnemonic_word_count do
      raise "Number of words must be one of the following: [12, 15, 18, 21, 24]"
    end

    sentence = for(word <- words, do: <<word_index(word)::size(11)>>, into: "")
    divider_index = floor(bit_size(sentence) / 33) * 32
    <<entropy::size(divider_index), checksum::bitstring>> = sentence

    ent = <<entropy::size(divider_index)>>
    cs = decode_integer(checksum)

    case checksum(ent) do
      {^cs, _} ->
        ent

      {other, _} ->
        raise "Invalid mnemonic (checksum mismatch): #{inspect(mnemonic)}. Got #{other}, expected: #{
                cs
              }"
    end
  end

  def maybe_decode(ent) do
    ent =
      case Base.decode16(ent, case: :mixed) do
        :error -> ent
        {:ok, decoded} -> decoded
      end

    bit_size(ent) in @valid_strenghts || raise "ENT must be #{inspect(@valid_strenghts)} bits"
    ent
  end

  def update_with_checksum(ent) do
    {checksum, checksum_size} = checksum(ent)
    <<ent::binary, checksum::size(checksum_size)>>
  end

  def sentence(ent_cs), do: bit_chunk(ent_cs, 11)

  def decode_integer(b) when is_bitstring(b) do
    b
    |> pad_leading_zeros()
    |> :binary.decode_unsigned(:big)
  end

  def word(i, lang \\ :english) when i in 0..2047 do
    lang
    |> wordlist_stream()
    |> Stream.filter(fn {_value, index} -> index == i end)
    |> Enum.at(0)
    |> elem(0)
    |> String.trim()
  end

  def word_index(word, lang \\ :english) when is_binary(word) do
    lang
    |> wordlist_stream()
    |> Stream.filter(fn {value, _index} -> String.trim(value) == word end)
    |> Enum.at(0)
    |> elem(1)
  end

  defp wordlist_stream(lang) do
    "priv/#{lang}.txt"
    |> File.stream!()
    |> Stream.with_index()
  end

  def checksum(ent) do
    s = div(bit_size(ent), 32)
    {bit_slice(:crypto.hash(:sha256, ent), s), s}
  end

  def pad_leading_zeros(bs) when is_binary(bs), do: bs

  def pad_leading_zeros(bs) when is_bitstring(bs) do
    pad_length = 8 - rem(bit_size(bs), 8)
    <<0::size(pad_length), bs::bitstring>>
  end

  def bit_chunk(b, n) when is_bitstring(b) and is_integer(n) and n > 1 do
    bit_chunk(b, n, [])
  end

  defp bit_chunk(b, n, acc) when bit_size(b) <= n do
    Enum.reverse([decode_integer(<<b::bitstring>>) | acc])
  end

  defp bit_chunk(b, n, acc) do
    <<chunk::size(n), rest::bitstring>> = b
    bit_chunk(rest, n, [decode_integer(<<chunk::size(n)>>) | acc])
  end

  defp bit_slice(bin, n) do
    <<x::integer-size(n), _t::bitstring>> = bin
    x
  end
end
