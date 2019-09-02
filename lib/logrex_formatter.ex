defmodule Logrex.Formatter do
  @moduledoc false

  alias IO.ANSI

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

  default_colors = %{
    enabled: true,
    debug: :cyan,
    info: :normal,
    warn: :yellow,
    error: :red
  }

  logger_colors =
    Application.get_env(:logger, :console, [])
    |> Keyword.get(:colors, [])
    |> Enum.into(%{})

  @colors Map.merge(default_colors, logger_colors)

  @level_names %{
    debug: ["DEBG", "DEBUG"],
    info: ["INFO", "INFO"],
    warn: ["WARN", "WARN"],
    error: ["EROR", "ERROR"]
  }

  @typep erl_datetime :: {{integer, integer, integer}, {integer, integer, integer, integer}}

  defguard inspect?(v) when is_list(v) or is_map(v) or is_pid(v) or is_tuple(v)

  @spec format(atom, String.t(), erl_datetime, keyword(any)) :: [bitstring(), ...]
  def format(level, message, timestamp, metadata) do
    config = Application.get_all_env(:logrex)

    {metadata, dynamic_fields} = split_metadata(metadata)

    meta_message =
      format_metadata(metadata, config)
      |> Kernel.<>(to_string(message))
      |> pad_message(config)

    [
      "\n",
      ANSI.format_fragment(@colors[level], @colors.enabled),
      level_name(level, config),
      " ",
      ANSI.format_fragment(:reset, @colors.enabled),
      format_time(timestamp),
      meta_message,
      format_dynamic_fields(dynamic_fields, @colors[level], config),
      "\n"
    ]
  end

  defp split_metadata(metadata) do
    metadata
    |> Enum.split_with(fn {k, _v} -> k in @default_metadata end)
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

  defp pad_message("", config) do
    case Keyword.get(config, :pad_empty_messages) do
      true -> pad_message(" ", config)
      _ -> ""
    end
  end

  defp pad_message(message, config) do
    padding = Keyword.get(config, :padding, @default_padding)
    String.pad_trailing(message, padding, " ") <> " "
  end

  defp format_dynamic_fields(fields, color, config) do
    fields
    |> Enum.map(fn {k, v} -> "#{format_dynamic_field(k, color)}=#{format_value(v, config)}" end)
    |> Enum.join(" ")
  end

  defp format_dynamic_field(field, color) do
    [
      ANSI.format_fragment(color, @colors.enabled),
      to_string(field),
      ANSI.format_fragment(:reset, @colors.enabled)
    ]
  end

  defp format_value(val, config) when inspect?(val) do
    case Keyword.get(config, :auto_inspect, true) do
      true ->
        inspect(val, pretty: true)

      _ ->
        to_string(val)
    end
  end

  defp format_value(val, _config), do: val

  defp level_name(level, config) do
    [short, long] = @level_names[level]

    case Keyword.get(config, :full_level_names) do
      true ->
        long

      _ ->
        short
    end
  end
end
