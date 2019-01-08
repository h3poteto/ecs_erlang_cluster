defmodule EcsErlangClusterTest do
  use ExUnit.Case
  doctest EcsErlangCluster

  test "greets the world" do
    assert EcsErlangCluster.hello() == :world
  end
end
