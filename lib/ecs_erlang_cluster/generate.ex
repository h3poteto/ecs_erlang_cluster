defmodule EcsErlangCluster.Generate do
  import SweetXml

  def run(cluster_name, service_name, file_name) do
    name_and_ips = sibling_tasks(cluster_name, service_name)
    |> Enum.map(fn(%{"task_id" => id, "private_ip" => ip}) -> "#{id}@#{ip}" end)
    file_name
    |> File.write(EEx.eval_file(
          "templates/sys.config.eex",
        [
          name_and_ips: name_and_ips
        ]))
  end

  def describe_tasks(tasks, cluster_name) do
    case ExAws.ECS.describe_tasks(tasks, cluster_name)
    |> ExAws.request!() do
      %{"tasks" => tasks} -> tasks
      _ -> []
    end
  end

  def list_task_arns(cluster_name, service_name) do
    case ExAws.ECS.list_tasks([{:cluster, cluster_name}, {:service_name, service_name}])
    |> ExAws.request!() do
      %{"taskArns" => tasks} -> tasks
      _ -> []
    end
  end

  def sibling_tasks(cluster_name, service_name) do
    list_task_arns(cluster_name, service_name)
    |> describe_tasks(cluster_name)
    |> Enum.map(fn(task) -> parser(task, cluster_name) end)
  end


  def parser(%{"containerInstanceArn" => container_instance_arn, "taskArn" => task_arn}, cluster_name) do
    ip = describe_container_instance(container_instance_arn, cluster_name)
    |> instance_private_ip()
    {:ok, id} = EcsErlangCluster.Oneself.parse_task_id(%{"TaskARN" => task_arn})
    %{"task_id" => id, "private_ip" => ip}
  end

  def describe_container_instance(arn, cluster_name) do
    case ExAws.ECS.describe_container_instances([arn], cluster_name)
    |> ExAws.request!() do
      %{"containerInstances" => instances} -> Enum.at(instances, 0)
      _ -> nil
    end
  end

  def instance_private_ip(%{"ec2InstanceId" => id}) do
    ExAws.EC2.describe_instances([instance_id: id])
    |> ExAws.request!()
    |> Map.get(:body)
    |> xpath(~x"//item/privateIpAddress/text()")
  end
end
