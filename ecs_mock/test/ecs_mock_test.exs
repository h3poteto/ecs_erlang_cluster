defmodule EcsMockTest do
  use ExUnit.Case
  doctest EcsMock

  test "greets the world" do
    assert EcsMock.hello() == :world
  end
end
