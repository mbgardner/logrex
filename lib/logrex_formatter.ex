defmodule Logrex.Formatter do
  @moduledoc """

  """

  @default_metadata [:application, :module, :function, :file, :line, :pid]
  @default_padding 44

  @typep erl_datetime :: {{integer, integer, integer}, {integer, integer, integer, integer}}

  @doc """
  Custom Logger format function, receives four arguments and returns a formatted
  string.
  """
  @spec format(atom, String.t, erl_datetime, keyword(any)) :: String.t
  def format(level, message, timestamp, metadata) do
    config = Application.get_all_env(:logrex)
    {level_display, level_color} = level_info(level)
    {metadata, dynamic_fields} = split_metadata(metadata)

    meta_message =
      format_metadata(metadata, config)
      |> Kernel.<>(to_string(message))
      |> pad_message(length(dynamic_fields), config)

    str =
      format_level(level_display, level_color)
      |> Kernel.<>(format_time(timestamp))
      |> Kernel.<>(meta_message)
      |> Kernel.<>(format_dynamic_fields(dynamic_fields, level_color))

    "\n" <> str <> "\n"
  end

  defp split_metadata(metadata) do
    metadata
    |> Enum.split_with(fn {k, _v} -> k in @default_metadata end)
  end

  defp format_level(display, color) do
    color <> display <> IO.ANSI.reset()
  end

  defp format_time({_date, {h, m, s, _ms}}) do
    {h, m, s}
    |> Time.from_erl!
    |> Time.to_string
    |> Kernel.<>(" ")
  end

  defp format_metadata([], _config), do: ""
  defp format_metadata(_metadata, ""), do: ""

  defp format_metadata(metadata, config) when is_list(config) do
    format = Keyword.get(config, :metadata_format, "")
    format_metadata(metadata, format)
  end

  defp format_metadata(metadata, format) when is_binary(format) do
    Enum.reduce(metadata, format, fn
      {:pid, v}, acc -> String.replace(acc, "$pid", inspect(v))
      {k, v}, acc -> String.replace(acc, "$#{k}", to_string(v))
    end)
  end

  defp pad_message(message, 0, _config), do: message
  defp pad_message(message, _num, config) do
    padding = Keyword.get(config, :padding, @default_padding)
    String.pad_trailing(message, padding, " ") <> " "
  end

  defp format_dynamic_fields(fields, level_color) do
    fields
    |> Enum.map(fn {k, v} -> "#{level_color}#{k}#{IO.ANSI.reset()}=#{v}" end)
    |> Enum.join(" ")
  end

  defp level_info(:debug), do: {"DEBG ", IO.ANSI.cyan()}
  defp level_info(:info), do: {"INFO ", IO.ANSI.normal()}
  defp level_info(:warn), do: {"WARN ", IO.ANSI.yellow()}
  defp level_info(:error), do: {"EROR ", IO.ANSI.red()}
  defp level_info(_), do: {"???? ", IO.ANSI.normal()}
end
