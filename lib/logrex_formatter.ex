defmodule Logrex.Formatter do

  @default_metadata [:application, :module, :function, :file, :line, :pid]
  @default_padding 44

  def format(level, message, timestamp, metadata) do
    config = Application.get_all_env(:logrex)
    {level_display, level_color} = level_info(level)
    {_standard_meta, dynamic_fields} = split_metadata(metadata)

    str =
      format_level(level_display, level_color)
      |> Kernel.<>(" ")
      |> Kernel.<>(format_time(timestamp))
      |> Kernel.<>(" ")
      |> Kernel.<>(format_message(message, length(dynamic_fields), config))
      |> Kernel.<>(" ")
      |> Kernel.<>(format_dynamic_fields(dynamic_fields, level_color))

    "\n" <> str <> "\n"
  end

  def split_metadata(metadata) do
    metadata
    |> Enum.split_with(fn {k, _v} -> k in @default_metadata end)
  end

  def format_level(display, color) do
    color <> display <> IO.ANSI.reset()
  end

  def format_time({_date, {h, m, s, _ms}}) do
    {h, m, s}
    |> Time.from_erl!
    |> Time.to_string
  end

  def format_message(message, 0, _config), do: message
  def format_message(message, _num_fields, config) do
    padding = Keyword.get(config, :padding, @default_padding)
    String.pad_trailing(message, padding, " ")
  end

  def format_dynamic_fields(fields, level_color) do
    fields
    |> Enum.map(fn {k, v} -> "#{level_color}#{k}#{IO.ANSI.reset()}=#{v}" end)
    |> Enum.join(" ")
  end

  def level_info(:debug), do: {"DEBG", IO.ANSI.cyan()}
  def level_info(:info), do: {"INFO", IO.ANSI.normal()}
  def level_info(:warn), do: {"WARN", IO.ANSI.yellow()}
  def level_info(:error), do: {"EROR", IO.ANSI.red()}
end
