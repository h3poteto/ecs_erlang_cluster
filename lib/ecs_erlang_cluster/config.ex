defmodule EcsErlangCluster.Config do
  def get_value(scope, key) do
    Application.get_env(scope, key)
    |> retrive_runtime_value
  end

  def retrive_runtime_value({:system, env_key}) do
    System.get_env(env_key)
  end

  def retrive_runtime_value(key) do
    key
  end
end
