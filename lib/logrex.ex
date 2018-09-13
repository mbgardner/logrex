defmodule Logrex do
  defmacro __using__(_opts) do
    quote do
      require Logger
      require Logrex
    end
  end

  defmacro info(chardata_or_fun, metadata \\ []) do
    quote do
      Logger.info(unquote(chardata_or_fun), unquote(build_metadata(metadata)))
    end
  end

  defp build_metadata(metadata) do
    metadata
    |> List.wrap
    |> Enum.map(fn
      {var, _, _} when is_atom(var) ->
        quote do: {unquote(var), var!(unquote(Macro.var(var, nil)))}
      {_, _} = var -> var
      ast -> build_path(ast)
    end)
    |> Enum.reverse
  end

  def build_path(ast) do
    {_, vars} = Macro.prewalk(ast, [], fn
      ({ var, _, x} = node, acc) when x in [nil] ->
        {node, [ var | acc ]}
      (node, acc) when node in [:get, Access] ->
        {node, acc}
      (node, acc) when is_atom(node) or is_binary(node) ->
        { node, [ node | acc ] }
      (node, acc) ->
        {node, acc}
    end)

    [ key | _tail ] = vars
    [ var | keys ] = Enum.reverse(vars)

    key = case key do
      k when is_binary(k) -> :erlang.binary_to_atom(key, :utf8)
      k -> k
    end

    quote do
      {unquote(key), get_in(var!(unquote(Macro.var(var, nil))), unquote(keys))}
    end
  end

  defdelegate format(level, message, timestamp, metadata), to: Logrex.Formatter
end
