[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)



# Mnemo

![](https://github.com/aerosol/mnemo/workflows/Elixir%20CI/badge.svg)
[![Hex.pm](https://img.shields.io/hexpm/v/mnemo.svg)](https://hex.pm/packages/mnemo)

Elixir implementation of [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki).

> (...) implementation of a mnemonic code or mnemonic sentence -- a group of easy to remember words -- for the generation of deterministic wallets.

`mnemo` library exposes the following interfaces:

  - [x] Generate random English mnemonic
  - [x] Generate English mnemonic for pre-existing binary entropy
  - [x] Convert English mnemonic back to its binary entropy
  - [x] Derive a PBKDF2 hex-encoded seed from any mnemonic 

The library is tested against reference vectors from [Trezor's implementation](https://github.com/trezor/python-mnemonic). Additionally, a simple property test guarantees mnemonic <-> entropy <-> mnemonic correctness.

## Examples

```
iex(1)> Mnemo.generate
"seminar depart parent awake canal relief age emotion swap area always near voyage exist idea aunt around burst uphold web tumble mimic reopen note"
```

```
iex(1)> mnemonic = "insect miracle play mad cream upgrade engage march absorb pyramid december observe jazz senior
 betray family valve peasant cargo marriage table laundry melody morning"
iex(2)> Mnemo.entropy(mnemonic, hex: true)
"7511ae9942d32fdd52943e00d5e0e2cc377787455a94f114448ac42dcefb62a4"
```

```
iex(1)> Mnemo.mnemonic :crypto.strong_rand_bytes(16)
"emotion enroll aspect taxi nerve warrior become lens cactus stand stage pretty"
```

```
iex(1)> Mnemo.generate |> Mnemo.seed
"18a644cfd59eb0b509b0a73639b01e836e9e5a09f1f473a7f1b967acebc1908a9c8afe4ad8fabe7928d11ea422ffabec42db07ca7085131196b7d3fb6a1d9bc4"
```

## Installation

The package can be installed by adding `mnemo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mnemo, "~> 0.1.0"}
  ]
end
```

## Documentation

Documentation can be generated locally with [ExDoc](https://github.com/elixir-lang/ex_doc).

The docs can be found at [https://hexdocs.pm/mnemo](https://hexdocs.pm/mnemo).
