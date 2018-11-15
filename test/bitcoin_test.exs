defmodule BITCOINTest do
  use ExUnit.Case
  doctest BITCOIN

  test "greets the world" do
    assert BITCOIN.hello() == :world
  end
end
