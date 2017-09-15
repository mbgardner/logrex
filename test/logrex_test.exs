defmodule LogrexTest do
  use ExUnit.Case
  doctest Logrex

  test "greets the world" do
    assert Logrex.hello() == :world
  end
end
