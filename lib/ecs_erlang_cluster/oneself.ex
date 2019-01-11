defmodule EcsErlangCluster.Oneself do
  def get() do
    {:ok, task} = task_id()
    {:ok, private_ip} = ip()
    "#{task}@#{private_ip}"
  end

  def task_id() do
    get_ecs_metadata()
    |> parse_task_id()
  end

  def task_arn() do
    get_ecs_metadata()
    |> parse_task_arn()
  end

  def get_ecs_metadata() do
    url = "#{Application.get_env(:metadata_endpoint, :ecs)}/task"
    result = HTTPoison.get!(url)
    case result do
      %{status_code: 200, body: body} -> Poison.decode!(body)
      %{status_code: code} -> {:error, code}
    end
  end

  def parse_task_id(%{"TaskARN" => arn}) do
    res = Regex.named_captures(~r/arn:aws:ecs:.+:task\/(?<id>.*?)$/, arn)
    case res do
      %{"id" => id} -> {:ok, id}
      _ -> {:error, nil}
    end
  end

  def parse_task_arn(%{"TaskARN" => arn}) do
    arn
  end

  def get_task_id({:error, code}) do
    {:error, code}
  end

  def ip() do
    #  On production EC2, it is http://169.254.169.254/latest/meta-data/local-ipv4.
    url = "#{Application.get_env(:metadata_endpoint, :ec2)}/latest/meta-data/local-ipv4"
    result = HTTPoison.get!(url)
    case result do
      %{status_code: 200, body: body} -> {:ok, body}
      %{status_code: code} -> {:error, code}
    end
  end
end
