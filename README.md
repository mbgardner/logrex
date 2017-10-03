# Logrex <img src="https://i.imgur.com/UEbtVhA.jpg" width="40" height="40" alt=":trex:" class="emoji" title=":trex:"/>

`Logrex` is an Elixir logging formatter inspired by [Logrus](https://github.com/sirupsen/logrus).
`Logrex` makes it simple to display dynamic fields outside of the inline text, for easier grokking and
parsing.

## Getting Started

To use `Logrex`, just install it via Hex and add some minor configuration.

### Installation

The latest version of `Logrex` is [available in Hex](https://hex.pm/docs/publish).
Add it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logrex, "~> 0.1.0"}
  ]
end
```

### Configuration

To use the `Logrex` formatter, add it to the standard console logger configuration
and set it to passthrough all metadata in `config/config.exs`:

```elixir
config :logger, :console,
  format: {Logrex.Console.Formatter, :format},
  metadata: :all
```

That will integrate `Logrex` with its default options:

```
iex(1)> require Logger
Logger
iex(2)> Logger.info "log message", field_a: 1, field_b: 2
:ok
iex(3)>
INFO 19:37:01 log message                                  field_a=1 field_b=2
```

Additionally, `Logrex` has its own optional configuration:

```elixir
config :logrex,
  padding: 44
```

## Documentation

`Logrex` documenation is published at [https://hexdocs.pm/logrex](https://hexdocs.pm/logrex).

## Running the tests

```shell
$ mix test
```

## To do

[] Add configurable level coloring
[] Use defaults based on mix environment if metadata format isn't provided

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* [Logrus](https://github.com/sirupsen/logrus)
* [Elixir Core Team](https://elixirforum.com/groups/Elixir-Core-Team)
