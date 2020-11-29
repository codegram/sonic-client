# SonicClient
![CI](https://github.com/codegram/sonic-client/workflows/CI/badge.svg)
![generate-docs](https://github.com/codegram/sonic-client/workflows/generate-docs/badge.svg)

Client library to interact with a [Sonic search backend](https://github.com/valeriansaliou/sonic) service.

🚨  This is still **pre-alpha** software and under heavy development. Use at you own risk. 🙂

This 

## Docs

The code documentation is automatically generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and
deployed here:
https://codegram.github.io/sonic-client/

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sonic_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sonic_client, "~> 0.2.0"}
  ]
end
```

## Testing sonic connection inside devcontainer

```bash
telnet sonic 1491
START control SecretPassword
PING
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sonic_client](https://hexdocs.pm/sonic_client).

