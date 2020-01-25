defmodule MnemoTest do
  use ExUnit.Case
  doctest Mnemo

  import Mnemo

  @vectors File.read!("priv/vectors.json") |> Jason.decode!() |> Map.fetch!("english")

  test "Vectors" do
    for [entropy, mnemonic | _] <- @vectors do
      IO.write(IO.ANSI.reset() <> "Vector: #{entropy}")
      assert mnemonic(entropy) == mnemonic
      IO.write(IO.ANSI.green() <> " ...OK\n")
    end
  end

  test "generate/1" do
    assert generate() |> String.split(" ") |> length == 12
    assert generate(160) |> String.split(" ") |> length == 15
    assert generate(192) |> String.split(" ") |> length == 18
    assert generate(224) |> String.split(" ") |> length == 21
    assert generate(256) |> String.split(" ") |> length == 24
  end

  for i <- 1..100 do
    test "proptest: entropy/1 (attempt #{i})" do
      mnemonic =
        [128, 160, 192, 224, 256] 
        |> Enum.random()
        |> generate()

      assert ^mnemonic = mnemonic |> entropy() |> mnemonic()
    end
  end

  describe "Words" do
    test "English words can be retrieved by index" do
      assert word(0) == "abandon"
      assert word(2047) == "zoo"
    end

    test "Index can be retrieved by English word" do
      assert word_index("abandon") == 0
      assert word_index("zoo") == 2047
    end
  end

  describe "Relations between entropy, checksum and length of mnemonic sentence" do
    test "ENT+CS=132 (12)", do: assert_ms(132, 12)

    test "ENT+CS=165 (15)", do: assert_ms(165, 15)

    test "ENT+CS=198 (18)", do: assert_ms(198, 18)

    test "ENT+CS=231 (21)", do: assert_ms(231, 21)

    test "ENT+CS=264 (24)", do: assert_ms(264, 24)

    test "ENT=128, CS=4", do: assert_cs(128, 4)

    test "ENT=160, CS=5", do: assert_cs(160, 5)

    test "ENT=192, CS=6", do: assert_cs(192, 6)

    test "ENT=224, CS=7", do: assert_cs(224, 7)

    test "ENT=256, CS=8", do: assert_cs(256, 8)

    defp assert_ms(ent_cs, ms) do
      ^ms = ceil(bit_size(<<1::size(ent_cs)>>) / 11)
      assert length(sentence(<<1::size(ent_cs)>>)) == ms
    end

    defp assert_cs(ent, cs), do: assert {_, ^cs} = checksum(<<1::size(ent)>>)
  end

  describe "Bits" do
    test "chunks" do
      assert [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        3
      ] = chunks(<<0::128, 3::4>>, 11)
    end

    test "pad_leading_zeros/1" do
      assert pad_leading_zeros(<<0>>) == <<0>>
      assert pad_leading_zeros(<<100>>) == <<100>>
      assert pad_leading_zeros(<<0::1>>) == <<0>>
      assert pad_leading_zeros(<<20::7>>) == <<20>>
      assert pad_leading_zeros(<<0, 0::4>>) == <<0, 0>>
    end

    test "decode_integer/1" do
      assert decode_integer(<<0>>) == 0
      assert decode_integer(<<0::1>>) == 0
      assert decode_integer(<<0::2>>) == 0
      assert decode_integer(<<0::3>>) == 0
      assert decode_integer(<<0::4>>) == 0
      assert decode_integer(<<0::5>>) == 0
      assert decode_integer(<<0::6>>) == 0
      assert decode_integer(<<0::7>>) == 0
      assert decode_integer(<<1>>) == 1
      assert decode_integer(<<1::16>>) == 1
      assert decode_integer(<<1, 0::4>>) == 16
    end
  end
end
