defmodule EcsErlangCluster.Oneself do
  def get() do
    {:ok, task_id} = task()
    {:ok, private_ip} = ip()
    "#{task_id}@#{private_ip}"
  end

  def task() do
    get_ecs_metadata()
    |> get_task_id()
  end

  def get_ecs_metadata() do
    url = "#{System.get_env("ECS_CONTAINER_METADATA_URI")}/task"
    result = HTTPoison.get!(url)
    case result do
      %{status_code: 200, body: body} -> Poison.decode!(body)
      %{status_code: code} -> {:error, code}
    end
  end

  def get_task_id(%{"TaskARN" => arn}) do
    res = Regex.named_captures(~r/arn:aws:ecs:.+:task\/(?<id>.*?)$/, arn)
    case res do
      %{"id" => id} -> {:ok, id}
      _ -> {:error, nil}
    end
  end

  def get_task_id({:error, code}) do
    {:error, code}
  end

  def ip() do
    #  On production EC2, it is http://169.254.169.254/latest/meta-data/local-ipv4.
    url = "#{System.get_env("EC2_METADATA_URI")}/latest/meta-data/local-ipv4"
    result = HTTPoison.get!(url)
    case result do
      %{status_code: 200, body: body} -> {:ok, body}
      %{status_code: code} -> {:error, code}
    end
  end
end
