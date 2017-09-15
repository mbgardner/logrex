defmodule Logrex do
  @moduledoc """
  Documentation for Logrex.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Logrex.hello
      :world

  """
  @behaviour :gen_event

  def init(__MODULE__) do
    {:ok, %{}}
  end

  def init({__MODULE__, opts}) when is_list(opts) do
    {:ok, configure(opts))
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, state) do
    IO.puts(inspect md)
    Logrex.Formatter.format(level, msg, ts, md)
    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  defp configure(name, opts) do
    state = %{name: nil, padding: nil, format: nil, level: nil, metadata: nil, metadata_filter: nil}
    configure(name, opts, state)
  end

  defp configure(name, opts, state) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level           = Keyword.get(opts, :level)
    metadata        = Keyword.get(opts, :metadata, [])
    format_opts     = Keyword.get(opts, :format, @default_format)
    format          = Logger.Formatter.compile(format_opts)
    path            = Keyword.get(opts, :path)
    metadata_filter = Keyword.get(opts, :metadata_filter)
    rotate          = Keyword.get(opts, :rotate)

    %{state | name: name, path: path, format: format, level: level, metadata: metadata, metadata_filter: metadata_filter, rotate: rotate}
  end
end

defmodule Logrex.Formatter do

  @default_metadata_length 5 # [:pid, :module, :function, :file, :line]

  def format(level, message, timestamp, metadata) do
    {l_name, l_color} = level_info(level)
    str = l_color <> "[#{l_name}] " <> IO.ANSI.reset()
    {default, custom} = Enum.split(metadata, @default_metadata_length)

    x =
      custom
      |> Enum.map(fn {k, v} -> "#{l_color}#{k}#{IO.ANSI.reset()}=#{v}" end)
      |> Enum.join(", ")

    IO.puts str <> message <> " #{x}"
  end

  def level_info(:debug), do: {"DEBG", IO.ANSI.green()}
  def level_info(:info), do: {"INFO", IO.ANSI.blue()}
  def level_info(:warn), do: {"WARN", IO.ANSI.yellow()}
  def level_info(:error), do: {"EROR", IO.ANSI.red()}

end
