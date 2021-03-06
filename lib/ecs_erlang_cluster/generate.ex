defmodule EcsErlangCluster.Generate do
  import SweetXml

  def run(cluster_name, service_name, file_name, region, min_port, max_port) do
    name_and_ips = sibling_tasks(cluster_name, service_name, region)
    |> Enum.map(fn(%{"task_id" => id, "private_ip" => ip}) -> "#{id}@#{ip}" end)
    file_name
    |> File.write(EEx.eval_string("""
    [{kernel,
      [
        {sync_nodes_optional, [<%= Enum.map(name_and_ips, fn(n) -> "'" <> n <> "'" end) |> Enum.join(", ") %>]},
        {sync_nodes_timeout, 10000},
        {inet_dist_listen_min, <%= min_port %>},
        {inet_dist_listen_max, <%= max_port %>}
      ]}
    ].
    """,
        [
          name_and_ips: name_and_ips,
          min_port: min_port,
          max_port: max_port
        ]))
  end

  def describe_tasks(tasks, cluster_name, region) do
    case ExAws.ECS.describe_tasks(tasks, cluster_name)
    |> ExAws.request!(region: region) do
      %{"tasks" => tasks} -> tasks
      _ -> []
    end
  end

  def list_task_arns(cluster_name, service_name, region) do
    case ExAws.ECS.list_tasks([{:cluster, cluster_name}, {:service_name, service_name}])
    |> ExAws.request!(region: region) do
      %{"taskArns" => tasks} -> tasks
      _ -> []
    end
  end

  def sibling_tasks(cluster_name, service_name, region) do
    list_task_arns(cluster_name, service_name, region)
    |> describe_tasks(cluster_name, region)
    |> Enum.map(fn(task) -> parser(task, cluster_name, region) end)
  end


  def parser(%{"containerInstanceArn" => container_instance_arn, "taskArn" => task_arn}, cluster_name, region) do
    ip = describe_container_instance(container_instance_arn, cluster_name, region)
    |> instance_private_ip(region)
    {:ok, id} = EcsErlangCluster.Oneself.parse_task_id(%{"TaskARN" => task_arn})
    %{"task_id" => id, "private_ip" => ip}
  end

  def describe_container_instance(arn, cluster_name, region) do
    case ExAws.ECS.describe_container_instances([arn], cluster_name)
    |> ExAws.request!(region: region) do
      %{"containerInstances" => instances} -> Enum.at(instances, 0)
      _ -> nil
    end
  end

  def instance_private_ip(%{"ec2InstanceId" => id}, region) do
    ExAws.EC2.describe_instances([instance_id: id])
    |> ExAws.request!(region: region)
    |> Map.get(:body)
    |> xpath(~x"//item/privateIpAddress/text()")
  end
end
