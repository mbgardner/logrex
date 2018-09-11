defmodule LogrexFormatterTest do
  use ExUnit.Case, seed: 0
  alias Logrex.Formatter

  describe "format/4" do

    test "it returns an info message" do
      result = Formatter.format(:info, "info message",
        {{1970, 1, 1}, {10, 20, 30, 500}}, [])
      expected = [
        "\n",
        "\e[22mINFO \e[0m",
        "10:20:30 ",
        "info message",
        "",
        "\n"
      ]
      assert result == expected
    end

    test "it returns a debug message with dynamic fields" do
      Application.put_env(:logrex, :padding, 44)
      Code.load_file("lib/logrex_formatter.ex")
      result = Formatter.format(:debug, "debug message",
        {{1970, 1, 1}, {10, 20, 30, 500}}, [a: 1])
      expected = [
        "\n",
        "\e[36mDEBG \e[0m", "10:20:30 ",
        "debug message                                ",
        "\e[36ma\e[0m=1",
        "\n"
      ]
      assert result == expected
    end

    test "it returns an error message with dynamic fields and custom padding" do
      Application.put_env(:logrex, :padding, 20)
      Code.load_file("lib/logrex_formatter.ex")
      result = Formatter.format(:error, "error message",
        {{1970, 1, 1}, {10, 20, 30, 500}}, [a: 1])
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

end
