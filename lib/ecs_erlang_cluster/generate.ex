defmodule EcsErlangCluster.Generate do
  import SweetXml

  def run(cluster_name, service_name, file_name, region) do
    name_and_ips = sibling_tasks(cluster_name, service_name, region)
    |> Enum.map(fn(%{"task_id" => id, "private_ip" => ip}) -> "#{id}@#{ip}" end)
    file_name
    |> File.write(EEx.eval_file(
          "lib/ecs_erlang_cluster/templates/sys.config.eex",
        [
          name_and_ips: name_and_ips
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
