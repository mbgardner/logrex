# Logrex <img src="https://i.imgur.com/UEbtVhA.jpg" width="40" height="40" alt=":trex:" class="emoji" title=":trex:"/>

`Logrex` is an Elixir logging formatter inspired by [Logrus](https://github.com/sirupsen/logrus).
`Logrex` makes it simple to display dynamic fields outside of the inline text, for easier grokking and
parsing.

## Getting Started

To use `Logrex`, just install it via Hex and add some minor configuration.

### Installation

The latest version of `Logrex` is [available in Hex](https://hex.pm/packages/logrex).
Add it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logrex, "~> 0.1.1"}
  ]
end
```

### Configuration

To use the `Logrex` formatter, add it to the standard console logger configuration
and set it to passthrough all metadata in `config/config.exs`:

```elixir
config :logger, :console,
  format: {Logrex.Formatter, :format},
  metadata: :all
```

That will integrate `Logrex` with its default options:

```
iex> require Logger
iex> Logger.info "message", foo: 1, bar: 2
INFO 02:31:06 message                                      foo=1 bar=2
```

Additionally, `Logrex` has its own optional configuration:

```elixir
config :logrex,
  auto_inspect: true,
  metadata_format: "$module $function:$line",
  padding: 50
```

## Documentation

`Logrex` documenation is published at [https://hexdocs.pm/logrex](https://hexdocs.pm/logrex).

## Running the tests

```shell
$ mix test
```

## To do

[] Add configurable level coloring

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* [Logrus](https://github.com/sirupsen/logrus)
* [Elixir Core Team](https://elixirforum.com/groups/Elixir-Core-Team)
