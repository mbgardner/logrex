# defmodule Logrexxx do
#   @moduledoc """
#   Documentation for Logrex.
#   """
#
#   @doc """
#   Hello world.
#
#   ## Examples
#
#       iex> Logrex.hello
#       :world
#
#   """
#   @behaviour :gen_event
#
#   @default_padding 45
#
#   defstruct [name: nil, level: nil, padding: @default_padding]
#
#   def init({__MODULE__, name}) when is_atom(name) do
#     {:ok, configure(name, [])}
#   end
#
#   def configure(name, opts), do: configure(name, opts, %__MODULE__{})
#   def configure(name, opts, state) do
#     env = Application.get_env(:logger, name, [])
#     opts = Keyword.merge(env, opts)
#     Application.put_env(:logger, name, opts)
#
#     level   = Keyword.get(opts, :level)
#     padding = Keyword.get(opts, :padding)
#
#     %{state | name: name, level: level, padding: padding}
#   end
#
#   def handle_event({level, _gl, {Logger, msg, ts, md}}, state) do
#     IO.puts(inspect md)
#     IO.puts(inspect ts)
#     #Logrex.Formatter.format(level, msg, ts, md)
#     format(level, msg, ts, md, state)
#     {:ok, state}
#   end
#
#   def format(level, message, timestamp, metadata, state) do
#     {l_display, l_color} = level_info(level)
#     str = l_color <> l_display <> IO.ANSI.reset() <> " " <> format_time(timestamp, state)
#     {default, custom} = Enum.split(metadata, @default_metadata_length)
#
#     x =
#       custom
#       |> Enum.map(fn {k, v} -> "#{l_color}#{k}#{IO.ANSI.reset()}=#{v}" end)
#       |> Enum.join(" ")
#
#     IO.puts str <> " " <> message <> " #{x}"
#   end
#
#   def format_time({_date, time}, state), do: format_time(time, state)
#
#   def format_time({h, m, s, ms}, %{display_millis: true}) do
#     {h, m, s}
#     |> Time.from_erl!
#     |> Time.to_string
#     |> (&(&1 <> ".#{ms}")).()
#   end
#
#   def format_time({h, m, s, ms}, %{display_millis: true}) do
#     {h, m, s}
#     |> Time.from_erl!
#     |> Time.to_string
#   end
#
#   def level_info(:debug), do: {"DEBG", IO.ANSI.cyan()}
#   def level_info(:info), do: {"INFO", IO.ANSI.normal()}
#   def level_info(:warn), do: {"WARN", IO.ANSI.yellow()}
#   def level_info(:error), do: {"EROR", IO.ANSI.red()}
#
#   def handle_event(:flush, state) do
#     {:ok, state}
#   end
#
#   def handle_call({:configure, opts}, %{name: name} = state) do
#     {:ok, state, configure(name, opts, state)}
#   end
# end
#
# defmodule Logrex.Formatter do
#
#   @default_metadata_length 5 # [:pid, :module, :function, :file, :line]
#
#   def format(level, message, timestamp, metadata) do
#     {l_display, l_color} = level_info(level)
#     str = l_color <> l_display <> IO.ANSI.reset() <> " " <> format_time(timestamp)
#     {default, custom} = Enum.split(metadata, @default_metadata_length)
#
#     x =
#       custom
#       |> Enum.map(fn {k, v} -> "#{l_color}#{k}#{IO.ANSI.reset()}=#{v}" end)
#       |> Enum.join(" ")
#
#     IO.puts str <> " " <> message <> " #{x}"
#   end
#
#   def format_time({_date, {h, m, s, _ms}}) do
#     {h, m, s}
#     |> Time.from_erl!
#     |> Time.to_string
#   end
#
#   def level_info(:debug), do: {"DEBG", IO.ANSI.cyan()}
#   def level_info(:info), do: {"INFO", IO.ANSI.normal()}
#   def level_info(:warn), do: {"WARN", IO.ANSI.yellow()}
#   def level_info(:error), do: {"EROR", IO.ANSI.red()}
#
# end
