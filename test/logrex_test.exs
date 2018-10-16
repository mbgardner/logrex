defmodule LogrexTest do
  use ExUnit.Case
  use Logrex

  import ExUnit.CaptureLog

  defstruct foo: "bar"

  describe "the generated metadata" do
    test "displays keyword lists" do
      fun = fn ->
        Logrex.info("test msg", a: 1, b: "two")
      end

      assert capture_log(fun) |> rem_color =~ "a=1 b=two"
    end

    test "displays a variable" do
      a = 1

      fun = fn ->
        Logrex.info("test msg", a)
      end

      assert capture_log(fun) |> rem_color =~ "a=1"
    end

    test "displays multiple variables" do
      a = 1
      b = %{foo: "bar"}

      fun = fn ->
        Logrex.info("test msg", [a, b])
      end

      assert capture_log(fun) |> rem_color =~ "a=1 b=%{foo: \"bar\"}"
    end

    test "displays mixed variables and keyword tuples" do
      a = 1
      b = %{foo: "bar"}

      fun = fn ->
        Logrex.info("test msg", [a, b, c: 2])
      end

      assert capture_log(fun) |> rem_color =~ "a=1 b=%{foo: \"bar\"} c=2"
    end

    test "displays embedded variables" do
      a = %{b: %{c: "d"}}
      x = %{"y" => "z"}

      fun = fn ->
        Logrex.info("test msg", [a.b, a.b.c, x["y"]])
      end

      assert capture_log(fun) |> rem_color =~ "b=%{c: \"d\"} c=d y=z"
    end

    test "displays structs" do
      t = %LogrexTest{}

      fun = fn ->
        Logrex.info("test msg", t.foo)
      end

      assert capture_log(fun) |> rem_color =~ "foo=bar"
    end

    test "displays mixed data types" do
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
    test "logs a debug message" do
      fun = fn -> Logrex.debug("debug msg") end

      assert capture_log(fun) =~ "DEBG"
      assert capture_log(fun) =~ "debug msg"
    end
  end

  describe "error/2" do
    test "logs an error message" do
      fun = fn -> Logrex.error("error msg") end

      assert capture_log(fun) =~ "EROR"
      assert capture_log(fun) =~ "error msg"
    end
  end

  describe "info/2" do
    test "logs an info message" do
      fun = fn -> Logrex.info("info msg") end

      assert capture_log(fun) =~ "INFO"
      assert capture_log(fun) =~ "info msg"
    end
  end

  describe "warn/2" do
    test "logs a warn message" do
      fun = fn -> Logrex.warn("warn msg") end

      assert capture_log(fun) =~ "WARN"
      assert capture_log(fun) =~ "warn msg"
    end
  end

  describe "meta/1" do
    test "logs a metadata message" do
      foo = %{bar: 1}
      fun = fn -> Logrex.meta([foo, foo.bar, a: 1]) end

      assert capture_log(fun) |> rem_color =~ "foo=%{bar: 1} bar=1 a=1"
    end

    test "logs a debug message by default" do
      fun = fn -> Logrex.meta(foo: "bar") end

      assert capture_log(fun) =~ "DEBG"
      assert capture_log(fun) |> rem_color =~ "foo=bar"
    end

    test "logs an error message if meta_level is :error" do
      Application.put_env(:logrex, :meta_level, :error)

      result = capture_log(fn ->
        defmodule LogrexTest.MetaError do
          use Logrex
          Logrex.meta(foo: "bar")
        end
      end)

      assert result =~ "EROR"
      assert result |> rem_color =~ "foo=bar"
    end

    test "logs an info message if meta_level is :info" do
      Application.put_env(:logrex, :meta_level, :info)

      result = capture_log(fn ->
        defmodule LogrexTest.MetaInfo do
          use Logrex
          Logrex.meta(foo: "bar")
        end
      end)

      assert result =~ "INFO"
      assert result |> rem_color =~ "foo=bar"
    end

    test "logs a warn message if meta_level is :warn" do
      Application.put_env(:logrex, :meta_level, :warn)

      result = capture_log(fn ->
        defmodule LogrexTest.MetaWarn do
          use Logrex
          Logrex.meta(foo: "bar")
        end
      end)

      assert result =~ "WARN"
      assert result |> rem_color =~ "foo=bar"
    end
  end

  defp rem_color(msg) do
    msg
    |> String.replace(~r/\e\[\d+m/, "")
  end
end
