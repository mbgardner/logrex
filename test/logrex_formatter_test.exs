defmodule LogrexFormatterTest do
  use ExUnit.Case

  alias Logrex.Formatter

  setup do
    # clear config fields
    Application.delete_env(:logrex, :auto_inspect)
    Application.delete_env(:logrex, :padding)
    Application.delete_env(:logrex, :pad_empty_messages)
  end

  describe "format/4" do
    test "returns an info message" do
      result = Formatter.format(:info, "info message", {{1970, 1, 1}, {10, 20, 30, 500}}, [])

      expected = [
        "\n",
        "\e[22mINFO \e[0m",
        "10:20:30 ",
        "info message                                 ",
        "",
        "\n"
      ]

      assert result == expected
    end

    test "returns a debug message with dynamic fields" do
      Application.put_env(:logrex, :padding, 44)

      result = Formatter.format(:debug, "debug message", {{1970, 1, 1}, {10, 20, 30, 500}}, a: 1)

      expected = [
        "\n",
        "\e[36mDEBG \e[0m",
        "10:20:30 ",
        "debug message                                ",
        "\e[36ma\e[0m=1",
        "\n"
      ]

      assert result == expected
    end

    test "returns an error message with dynamic fields and custom padding" do
      Application.put_env(:logrex, :padding, 20)

      result = Formatter.format(:error, "error message", {{1970, 1, 1}, {10, 20, 30, 500}}, a: 1)

      expected = [
        "\n",
        "\e[31mEROR \e[0m",
        "10:20:30 ",
        "error message        ",
        "\e[31ma\e[0m=1",
        "\n"
      ]

      assert result == expected
    end
  end

  describe "auto_inspect config" do
    test "inspects lists" do
      a = [1, 2]

      result = Formatter.format(:info, "msg", {{1970, 1, 1}, {10, 20, 30, 500}}, a: a)

      assert result |> Enum.join("") |> rem_color =~ "a=[1, 2]"
    end

    test "inspects maps" do
      a = %{b: "c"}

      result = Formatter.format(:info, "msg", {{1970, 1, 1}, {10, 20, 30, 500}}, a: a)

      assert result |> Enum.join("") |> rem_color =~ "a=%{b: \"c\"}"
    end

    test "inspects pids" do
      a = self()

      result = Formatter.format(:info, "msg", {{1970, 1, 1}, {10, 20, 30, 500}}, a: a)

      assert result |> Enum.join("") |> rem_color =~ "a=#{inspect(self())}"
    end

    test "inspects tuples" do
      a = {"foo", "bar"}

      result = Formatter.format(:info, "msg", {{1970, 1, 1}, {10, 20, 30, 500}}, a: a)

      assert result |> Enum.join("") |> rem_color =~ "a={\"foo\", \"bar\"}"
    end

    test "raises if set to false and given a value that requires inspect" do
      Application.put_env(:logrex, :auto_inspect, false)
      a = %{b: "c"}

      fun = fn ->
        Formatter.format(:info, "msg", {{1970, 1, 1}, {10, 20, 30, 500}}, a: a)
      end

      assert_raise(Protocol.UndefinedError, fun)
    end
  end

  describe "pad_empty_message config" do
    test "pads an empty message if set to true" do
      Application.put_env(:logrex, :padding, 10)
      Application.put_env(:logrex, :pad_empty_messages, true)

      result = Formatter.format(:info, "", {{1970, 1, 1}, {10, 20, 30, 500}}, a: 1)
      expect = "10:20:30            a=1"
      assert result |> Enum.join("") |> rem_color =~ expect
    end

    test "doesn't pad an empty message if not set" do
      Application.put_env(:logrex, :padding, 10)

      result = Formatter.format(:info, "", {{1970, 1, 1}, {10, 20, 30, 500}}, a: 1)
      expect = "10:20:30 a=1"
      assert result |> Enum.join("") |> rem_color =~ expect
    end
  end

  defp rem_color(msg) do
    msg
    |> String.replace(~r/\e\[\d+m/, "")
  end
end
