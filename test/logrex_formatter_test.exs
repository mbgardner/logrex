defmodule LogrexFormatterTest do
  use ExUnit.Case
  alias Logrex.Formatter
  doctest Formatter

  describe "format/4" do

    test "it returns the log message" do
      result = Formatter.format(:info, "test message",
        {{1970, 1, 1}, {10, 20, 30, 500}}, [])
      expected = "\n#{IO.ANSI.normal()}INFO #{IO.ANSI.reset()}10:20:30 test message\n"
      assert result == expected

      # dynamic fields
      result = Formatter.format(:debug, "test message",
        {{1970, 1, 1}, {10, 20, 30, 500}}, [a: 1])
      expected = "\n#{IO.ANSI.cyan()}DEBG #{IO.ANSI.reset()}10:20:30 " <>
        String.pad_trailing("test message", 44, " ") <>
        " #{IO.ANSI.cyan()}a#{IO.ANSI.reset()}=1\n"
      assert result == expected

      # dynamic fields + custom padding
      Application.put_env(:logrex, :padding, 5)
      result = Formatter.format(:debug, "test message",
        {{1970, 1, 1}, {10, 20, 30, 500}}, [a: 1])
      expected = "\n#{IO.ANSI.cyan()}DEBG #{IO.ANSI.reset()}10:20:30 " <>
        String.pad_trailing("test message", 5, " ") <>
        " #{IO.ANSI.cyan()}a#{IO.ANSI.reset()}=1\n"
      assert result == expected
    end

  end

end
