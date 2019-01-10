defmodule Ec2MockTest do
  use ExUnit.Case
  doctest Ec2Mock

  test "greets the world" do
    assert Ec2Mock.hello() == :world
  end
end
