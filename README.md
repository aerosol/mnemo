# Mnemo

Elixir implementation of [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki).

> (...) implementation of a mnemonic code or mnemonic sentence -- a group of easy to remember words -- for the generation of deterministic wallets.

`mnemo` library exposes the following interfaces:

  - [x] Generate random English mnemonic
  - [x] Generate English mnemonic for pre-existing binary entropy
  - [x] Convert English mnemonic back to its binary entropy
  - [x] Derive a PBKDF2 hex-encoded seed from any mnemonic 

The library is tested against reference vectors from [Trezor's implementation](https://github.com/trezor/python-mnemonic). Additionally, a simple property test guarantees mnemonic <-> entropy <-> mnemonic correctness.

## Installation

The package can be installed by adding `mnemo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mnemo, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
The docs can be found at [https://hexdocs.pm/mnemo](https://hexdocs.pm/mnemo).
