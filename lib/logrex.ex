defmodule Logrex do
  @moduledoc """
  An Elixir package for more easily adding Logger metadata and formatting the
  console output so it's easier for humans to parse.

  It wraps Elixir's Logger module to let you write code like this:

  ```
  > use Logrex
  > name = "Matt"
  > user_info = %{login_count: 1}
  > Logrex.info "New login", [name, user_info.login_count]
  ```

  To display this:

  ```
  > INFO 20:56:40 New login                    user=Matt login_count=1
  ```
  """

  @doc """
  Custom Logger format function, which receives the Logger arguments and
  returns a string with formatted key/value metadata pairs broken out to the
  right of the message.
  """
  defdelegate format(level, message, timestamp, metadata), to: Logrex.Formatter

  defmacro __using__(_opts) do
    quote do
      require Logger
      require Logrex
    end
  end

  @doc """
  Log a debug message with dynamic metadata.
  """
  defmacro debug(chardata_or_fun, metadata \\ []) do
    quote do
      Logger.debug(unquote(chardata_or_fun), unquote(build_metadata(metadata)))
    end
  end

  @doc """
  Log an error message with dynamic metadata.
  """
  defmacro error(chardata_or_fun, metadata \\ []) do
    quote do
      Logger.error(unquote(chardata_or_fun), unquote(build_metadata(metadata)))
    end
  end

  @doc """
  Log an info message with dynamic metadata.
  """
  defmacro info(chardata_or_fun, metadata \\ []) do
    quote do
      Logger.info(unquote(chardata_or_fun), unquote(build_metadata(metadata)))
    end
  end

  @doc """
  Log a warning message with dynamic metadata.
  """
  defmacro warn(chardata_or_fun, metadata \\ []) do
    quote do
      Logger.warn(unquote(chardata_or_fun), unquote(build_metadata(metadata)))
    end
  end

  @doc """
  Logs a metadata-only message.

  It is a shorthand and more explicit way of using one of the level
  functions with an empty string as the first parameter. By default, all
  `meta/1` calls are logged as debug, but that can be changed via the
  `:meta_level` config.

  ## Examples

      Logrex.meta foo: bar
      Logrex.meta [var1, var2]

  """
  defmacro meta(metadata \\ []) do
    level = Application.get_env(:logrex, :meta_level, :debug)

    case level do
      :debug ->
        quote do
          Logger.debug("", unquote(build_metadata(metadata)))
        end

      :error ->
        quote do
          Logger.error("", unquote(build_metadata(metadata)))
        end

      :info ->
        quote do
          Logger.info("", unquote(build_metadata(metadata)))
        end

      :warn ->
        quote do
          Logger.warn("", unquote(build_metadata(metadata)))
        end
    end
  end

  defp build_metadata(metadata) do
    metadata
    |> List.wrap()
    |> Enum.map(fn
      {var, _, _} when is_atom(var) ->
        quote do: {unquote(var), var!(unquote(Macro.var(var, nil)))}

      {_, _} = var ->
        var

      ast ->
        build_path(ast)
    end)
    |> Enum.reverse()
  end

  defp build_path(ast) do
    {_, vars} =
      Macro.prewalk(ast, [], fn
        {var, _, x} = node, acc when x in [nil] ->
          {node, [var | acc]}

        node, acc when node in [:get, Access] ->
          {node, acc}

        node, acc when is_atom(node) or is_binary(node) ->
          {node, [node | acc]}

        node, acc ->
          {node, acc}
      end)

    [meta_key | _tail] = vars
    [var | key_path] = Enum.reverse(vars)

    meta_key =
      case meta_key do
        k when is_binary(k) -> :erlang.binary_to_atom(meta_key, :utf8)
        k -> k
      end

    quote do
      {unquote(meta_key),
       get_in(Map.delete(var!(unquote(Macro.var(var, nil))), :__struct__), unquote(key_path))}
    end
  end
end
