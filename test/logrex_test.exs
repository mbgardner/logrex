defmodule LogrexTest do
  use ExUnit.Case
  use Logrex

  import ExUnit.CaptureLog

  defstruct foo: "bar"

  describe "generated metadata" do
    test "should display keyword lists" do
      fun = fn ->
        Logrex.info("test msg", a: 1, b: "two")
      end

      assert capture_log(fun) |> rem_color =~ "a=1 b=two"
    end

    test "should display a variable" do
      a = 1

      fun = fn ->
        Logrex.info("test msg", a)
      end

      assert capture_log(fun) |> rem_color =~ "a=1"
    end

    test "should display multiple variables" do
      a = 1
      b = %{foo: "bar"}

      fun = fn ->
        Logrex.info("test msg", [a, b])
      end

      assert capture_log(fun) |> rem_color =~ "a=1 b=%{foo: \"bar\"}"
    end

    test "should display mixed variables and keyword tuples" do
      a = 1
      b = %{foo: "bar"}

      fun = fn ->
        Logrex.info("test msg", [a, b, c: 2])
      end

      assert capture_log(fun) |> rem_color =~ "a=1 b=%{foo: \"bar\"} c=2"
    end

    test "should display embedded variables" do
      a = %{b: %{c: "d"}}
      x = %{"y" => "z"}

      fun = fn ->
        Logrex.info("test msg", [a.b, a.b.c, x["y"]])
      end

      assert capture_log(fun) |> rem_color =~ "b=%{c: \"d\"} c=d y=z"
    end

    test "should display structs" do
      t = %LogrexTest{}

      fun = fn ->
        Logrex.info("test msg", t.foo)
      end

      assert capture_log(fun) |> rem_color =~ "foo=bar"
    end

    test "should display mixed data types" do
      struct = %LogrexTest{}
      map = %{a: %{"b" => "c"}}
      pid_id = self() # 'pid' is a Logger metadata field
      pid_map = %{pid_id: pid_id}
      list = [1, 2, 3]
      tuple = {1, 2}

      fun = fn ->
        Logrex.info("test msg", [
          struct.foo,
          map,
          map.a["b"],
          pid_id,
          pid_map,
          list,
          tuple,
          inline: "val"
        ])
      end

      pstr = inspect(self())

      expected =
        "foo=bar map=%{a: %{\"b\" => \"c\"}} b=c pid_id=#{pstr} pid_map=%{pid_id: #{pstr}} list=[1, 2, 3] tuple={1, 2} inline=val"

      assert capture_log(fun) |> rem_color =~ expected
    end
  end

  describe "debug/2" do
    test "should log a debug message" do
      fun = fn -> Logrex.debug("debug msg") end

      assert capture_log(fun) =~ "DEBG"
      assert capture_log(fun) =~ "debug msg"
    end
  end

  describe "error/2" do
    test "should log an error message" do
      fun = fn -> Logrex.error("error msg") end

      assert capture_log(fun) =~ "EROR"
      assert capture_log(fun) =~ "error msg"
    end
  end

  describe "info/2" do
    test "should log an info message" do
      fun = fn -> Logrex.info("info msg") end

      assert capture_log(fun) =~ "INFO"
      assert capture_log(fun) =~ "info msg"
    end
  end

  describe "warn/2" do
    test "should log a warn message" do
      fun = fn -> Logrex.warn("warn msg") end

      assert capture_log(fun) =~ "WARN"
      assert capture_log(fun) =~ "warn msg"
    end
  end

  defp rem_color(msg) do
    msg
    |> String.replace(~r/\e\[\d+m/, "")
  end
end
