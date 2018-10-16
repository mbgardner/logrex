# Logrex <img src="https://i.imgur.com/UEbtVhA.jpg" width="40" height="40" alt=":trex:" class="emoji" title=":trex:"/>

An Elixir package for more easily adding [Logger](https://hexdocs.pm/logger/Logger.html)
metadata and formatting the console output so it's easier for humans to parse.

It lets you write code like this:

```elixir
user = "Matt"
login_info = %{total_logins: 10, from: "example.com"}
Logrex.info "New login", [user, login_info.from, login_info.total_logins]
```

To display this:

```
INFO 20:56:40 New login               user=Matt from=example.com total_logins=10
```

## Getting Started

To start using Logrex, install it via Hex.

### Installation

The latest version of Logrex is [available in Hex](https://hex.pm/packages/logrex).
Add it to your list of dependencies in your `mix.exs` file:

```elixir
def deps do
  [
    {:logrex, "~> 0.3.0"}
  ]
end
```

### Use Logrex

To call Logrex functions in your modules, add `use Logrex` to the top.

```elixir
defmodule SomeModule do
  use Logrex
  
  def some_fun do
    foo = "bar"
    Logrex.info "some message", foo
  end
end
```

Logrex requires Logger for you.

### Logrex Features

There are two features in Logrex that can be used together or separately;
generation of metadata and the console formatter.

#### Metadata Generation

Using metadata fields to capture metrics and other values of interest in log
output works really well, but a common pattern arises where variable names and
their corresponding keys are duplicated. Take the following example:

```elixir
%{name: name, login_count: login_count} = user
Logger.info "User login", name: name, login_count: login_count
```

Logrex exposes macros, matching the Logger macros, which generate the
keyword list passed as the metadata parameter to the Logger functions. Both of
the examples below will generate the same `Logger.info/2` output as the example above.

You can use the matched variables directly:

```elixir
%{name: name, login_count: login_count} = user
Logrex.info "User login", [name, login_count]
```

Or you can access the map keys, which will be used for the metadata keys:

```elixir
Logrex.info "User login", [user.name, user.login_count]
```

For metadata generation, you must `use Logrex` at the top of your module, which
itself requires Logger.

> Note that Elixir syntax rules apply, if you want to mix variables and keyword
> tuples via shorthand, you have to place them inside brackets and the tuples
> have to be last. For example, this is valid:
>
> Logrex.info "msg", [a, b, c: 1]
>
> And these aren't:
>
> Logrex.info "msg", a, b
>
> Logrex.info "msg", [c: 1, a, b]

#### Console Formatter

By default, the Elixir Logger defines a whitelist of metadata fields and
requires that any additional fields be explicitly added. The Logrex formatter
instead allows for dynamic metadata fields and separates them from the inline
log text.

To use the Logrex console formatter, set it as the console formatter in your
logger configuration, and set it to passthrough all metadata fields.

```elixir
config :logger, :console,
  format: {Logrex, :format},
  metadata: :all
```

That will pass log output to the formatter with its default options:

```
iex> require Logger
iex> Logger.info "message", foo: 1, bar: 2
INFO 02:31:06 message                                      foo=1 bar=2
```

> Note in the example above that the formatter does not rely on using Logrex's
> metadata generation, you can use it by itself with Logger.

Additionally, Logrex has its own optional formatting configuration.

#### Formatter Configuration Options

Config | Default | Description
-------| ------- | -----------
`auto_inspect` | true | the Logrex formatter will automatically call inspect on metadata values which are lists, maps, pids, or tuples
`metadata_format` | empty string | the format for system metadata fields, as described in the [Logger docs](https://hexdocs.pm/logger/Logger.html#module-metadata); system metadata is displayed between the time and the log message
`meta_level` | :debug | the level to log Logrex.meta/1 messages
`padding` | 44 | the minimum character width of the main log message
`pad_empty_messages` | false | the Logrex formatter will not apply padding to empty messages, unless set to 'true'

Example Formatter Configuration Setup:

```elixir
config :logrex,
  metadata_format: "$module $function:$line",
  meta_level: :info,
  padding: 50
```

## Documentation

Logrex documenation is published at [https://hexdocs.pm/logrex](https://hexdocs.pm/logrex).

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
