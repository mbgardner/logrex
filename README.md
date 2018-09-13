# Logrex <img src="https://i.imgur.com/UEbtVhA.jpg" width="40" height="40" alt=":trex:" class="emoji" title=":trex:"/>

`Logrex` is an Elixir package for more easily adding Logger metadata and
formatting it to be more presentable to humans.

It lets you write code like this:

```elixir
some_num = 1
map = %{foo: "bar"}
Logrex.info "Some text", [some_num, some_map: map]
```

To print this:

```
INFO 20:56:40 Some text                  some_num=1 some_map=%{foo: "bar"}
```

## Getting Started

To start using `Logrex`, install it via Hex and decide which parts you
want to use.

### Installation

The latest version of `Logrex` is [available in Hex](https://hex.pm/packages/logrex).
Add it to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logrex, "~> 0.2.0"}
  ]
end
```

### Logrex Modules

There are two modules you might care about in Logrex; the main Logrex
module, which makes it easier to add metadata, and Logrex.Formatter module, which formats
metadata to be more presentable.




### Configuration

To use the `Logrex` formatter, add it to the standard console logger configuration
and set it to passthrough all metadata in `config/config.exs`:

```elixir
config :logger, :console,
  format: {Logrex, :format},
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
