defmodule LogrexFormatterTest do
  use ExUnit.Case
  alias Logrex.Formatter
  doctest Formatter

  describe "format_time/1" do

    test "it returns a formatted time string" do
      str = Formatter.format_time({{1, 1, 1970}, {10, 20, 30, 500}})
      assert str == "10:20:30"

      str = Formatter.format_time({{1, 1, 1970}, {1, 20, 3, 500}})
      assert str == "01:20:03"
    end

  end

end
