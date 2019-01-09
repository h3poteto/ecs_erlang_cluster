defmodule EcsMock do
  use Trot.Router

  get "/task" do
    %{
      "Cluster" => "ecs-cluster",
      "TaskARN" => "arn:aws:ecs:ap-northeast-1:12345678:task/59f37e53-b11b-4f21-a43a-c547808797a2",
      "Family" => "ecs-task",
      "Revision" => "7",
      "DesiredStatus" => "RUNNING",
      "KnownStatus" => "RUNNING",
      "Containers" => [
        %{
          "DockerId" => "1efa1f977ddda146146bee071ceeb449c18cba7a5672c806b7f487a6d3d2d070",
          "Name" => "phoenix",
          "DockerName" => "ecs-task-7-phoenix-d8d5e1eafdc9d4cd6300",
          "Image" => "12345678.dkr.ecr.ap-northeast-1.amazonaws.com/image:hash",
          "ImageID" => "sha256:21137675b1ceb76ac2e5a2fd6d306155ffab3b5f5f6cc3f6c8392d782f8bcdf4",
          "Ports" => [
            %{"ContainerPort" => 8080, "Protocol" => "tcp"}
          ],
          "Labels" => %{
            "com.amazonaws.ecs.cluster" => "base-default-prd",
            "com.amazonaws.ecs.container-name" => "phoenix",
            "com.amazonaws.ecs.task-arn" => "arn:aws:ecs:ap-northeast-1:12345678:task/59f37e53-b11b-4f21-a43a-c547808797a2",
            "com.amazonaws.ecs.task-definition-family" => "ecs-task",
            "com.amazonaws.ecs.task-definition-version" => "7"
          },
          "DesiredStatus" => "RUNNING",
          "KnownStatus" => "RUNNING",
          "Limits" => %{
            "CPU" => 333,
            "Memory" => 300
          },
          "CreatedAt" => "2019-01-07T23:37:59.105591604Z",
          "StartedAt" => "2019-01-07T23:37:59.814495901Z",
          "Type" => "NORMAL"
        }
      ],
      "PullStartedAt" => "2019-01-07T23:37:17.270214078Z",
      "PullStoppedAt" => "2019-01-07T23:37:59.101603274Z"
    }
  end

  import_routes Trot.NotFound
end
