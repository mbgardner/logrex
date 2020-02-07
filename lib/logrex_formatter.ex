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

  @default_colors %{
    enabled: true,
    debug: :cyan,
    info: :normal,
    warn: :yellow,
    error: :red
  }

  @level_names %{
    debug: %{short: "DEBG", long: "DEBUG"},
    info: %{short: "INFO", long: "INFO"},
    warn: %{short: "WARN", long: "WARN"},
    error: %{short: "EROR", long: "ERROR"}
  }

  @typep erl_datetime :: {{integer, integer, integer}, {integer, integer, integer, integer}}

  defguard inspect?(v) when is_list(v) or is_map(v) or is_pid(v) or is_tuple(v) or is_function(v)

  @spec format(atom, String.t(), erl_datetime, keyword(any)) :: [bitstring(), ...]
  def format(level, message, timestamp, metadata) do
    config = Application.get_all_env(:logrex) |> Enum.into(%{})
    colors = get_colors()

    {metadata, dynamic_fields} = split_metadata(metadata)

    meta_message =
      format_metadata(metadata, config)
      |> Kernel.<>(to_string(message))
      |> pad_message(config)

    [
      "\n",
      ANSI.format_fragment(colors[level], colors.enabled),
      level_name(level, config),
      " ",
      ANSI.format_fragment(:reset, colors.enabled),
      format_timestamp(timestamp, config),
      meta_message,
      format_dynamic_fields(dynamic_fields, level, colors, config),
      "\n"
    ]
  end

  defp split_metadata(metadata) do
    metadata
    |> Enum.split_with(fn {k, _v} -> k in @default_metadata end)
  end

  defp format_timestamp({date, {h, m, s, _ms}}, %{show_date: true}) do
    {date, {h, m, s}}
    |> NaiveDateTime.from_erl!
    |> NaiveDateTime.to_iso8601()
    |> Kernel.<>(" ")
  end

  defp format_timestamp({_date, {h, m, s, _ms}}, _config) do
    {h, m, s}
    |> Time.from_erl!()
    |> Time.to_string()
    |> Kernel.<>(" ")
  end

  # format system metadata
  defp format_metadata(metadata, %{metadata_format: format} = config) do
    Enum.reduce(metadata, format, fn
      {:module, v}, acc -> String.replace(acc, "$module", format_module(v, config))
      {:pid, v}, acc -> String.replace(acc, "$pid", inspect(v))
      {k, v}, acc -> String.replace(acc, "$#{k}", to_string(v))
    end)
  end

  defp format_metadata(_metadata, _config), do: ""

  defp format_module(name, %{show_elixir_prefix: true}), do: to_string(name)
  defp format_module(name, _), do: String.replace_prefix(to_string(name), "Elixir.", "")

  defp pad_message("", %{pad_empty_messages: true} = config), do: pad_message(" ", config)
  defp pad_message("", _config), do: ""

  defp pad_message(message, config) do
    padding = Map.get(config, :padding, @default_padding)
    String.pad_trailing(message, padding, " ") <> " "
  end

  defp format_dynamic_fields(fields, level, colors, config) do
    fields
    |> Enum.map(fn {k, v} ->
      "#{format_dynamic_field(k, level, colors)}=#{format_value(v, config)}"
    end)
    |> Enum.join(" ")
  end

  defp format_dynamic_field(field, level, %{enabled: true} = colors) do
    [
      ANSI.format_fragment(colors[level]),
      to_string(field),
      ANSI.format_fragment(:reset)
    ]
  end

  defp format_dynamic_field(field, _level, _colors), do: [to_string(field)]

  defp format_value(val, %{auto_inspect: false}) when inspect?(val), do: to_string(val)
  defp format_value(val, %{auto_inspect: false}), do: val
  defp format_value(val, _config) do
    if !String.Chars.impl_for(val) or is_list(val) do
      inspect(val)
    else
      val
    end
  end

  defp level_name(level, %{full_level_names: true}), do: @level_names[level].long
  defp level_name(level, _config), do: @level_names[level].short

  defp get_colors do
    logger_colors =
      Application.get_env(:logger, :console, [])
      |> Keyword.get(:colors, [])
      |> Enum.into(%{})

    Map.merge(@default_colors, logger_colors)
  end
end
