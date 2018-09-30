defmodule Logrex.Formatter do
  @moduledoc false

  @default_metadata [
    :application,
    :module,
    :function,
    :file,
    :line,
    :pid,
    :crash_reason,
    :initial_call,
    :registered_name
  ]
  @default_padding 44

  @typep erl_datetime :: {{integer, integer, integer}, {integer, integer, integer, integer}}

  defguard inspect?(v) when is_list(v) or is_map(v) or is_pid(v) or is_tuple(v)

  @spec format(atom, String.t(), erl_datetime, keyword(any)) :: [bitstring(), ...]
  def format(level, message, timestamp, metadata) do
    config = Application.get_all_env(:logrex)
    {level_display, level_color} = level_info(level)
    {metadata, dynamic_fields} = split_metadata(metadata)

    meta_message =
      format_metadata(metadata, config)
      |> Kernel.<>(to_string(message))
      |> pad_message(length(dynamic_fields), config)

    [
      "\n",
      format_level(level_display, level_color),
      format_time(timestamp),
      meta_message,
      format_dynamic_fields(dynamic_fields, level_color, config),
      "\n"
    ]
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
    |> Time.from_erl!()
    |> Time.to_string()
    |> Kernel.<>(" ")
  end

  # format system metadata
  defp format_metadata(metadata, metadata_format: format) do
    Enum.reduce(metadata, format, fn
      {:pid, v}, acc -> String.replace(acc, "$pid", inspect(v))
      {k, v}, acc -> String.replace(acc, "$#{k}", to_string(v))
    end)
  end

  defp format_metadata([], _config), do: ""
  defp format_metadata(metadata, _config), do: format_metadata(metadata, metadata_format: "")

  defp pad_message(message, 0, _config), do: message

  defp pad_message(message, _meta, padding: padding) do
    String.pad_trailing(message, padding, " ") <> " "
  end

  defp pad_message(message, meta, _config) do
    pad_message(message, meta, padding: @default_padding)
  end

  defp format_dynamic_fields(fields, level_color, config) do
    fields
    |> Enum.map(fn {k, v} ->
      "#{level_color}#{k}#{IO.ANSI.reset()}=#{format_value(v, config)}"
    end)
    |> Enum.join(" ")
  end

  defp format_value(val, auto_inspect: false), do: val
  defp format_value(val, _config) when inspect?(val), do: inspect(val, pretty: true)
  defp format_value(val, _config), do: val

  defp level_info(:debug), do: {"DEBG ", IO.ANSI.cyan()}
  defp level_info(:info), do: {"INFO ", IO.ANSI.normal()}
  defp level_info(:warn), do: {"WARN ", IO.ANSI.yellow()}
  defp level_info(:error), do: {"EROR ", IO.ANSI.red()}
end
