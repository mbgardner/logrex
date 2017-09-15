# Logrex

Logrex is an Elixir logging library inspired by [Logrus](https://github.com/sirupsen/logrus). Logrex makes it simple
to display fields and values outside of the log text, for a cleaner output and
easier parsing.

Logrex differs from the standard Elixir console logger in that it doesn't
require a whitelist of fields to be defined in order for those fields to be
displayed. In that regard, it's essentially just a passthrough to a formatter.
Logrex uses its own formatter by default, but a custom formatter can be provided
via the standard API.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `logrex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logrex, "~> 0.1.0"}
  ]
end
```

## Usage

The Logrex module is essentially a passthrough to a formatter,

## Example

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/logrex](https://hexdocs.pm/logrex).
