# ECSErlangCluster

[![GitHub release](https://img.shields.io/github/release/h3poteto/ecs_erlang_cluster.svg?style=flat-square)](https://github.com/h3poteto/ecs_erlang_cluster/releases)

This is a command line tool to create the Erlang cluster on AWS ECS. When start a ECS task, it needs `sys.config` and own identifier and IP address for Erlang cluster. Other node's identifiers and IP addresses are written in `sys.config`.

`ecs_erlang_cluster` command can get own identifier and IP address, and can generate `sys.config` which has sibling nodes identifier and IP address. So you only have to launch the application by passing the result of this command.

## Installation

This is an escript command, so you can install using mix command.

```bash
$ mix escript.install github h3poteto/ecs_erlang_cluster
* Getting new package (https://github.com/h3poteto/ecs_erlang_cluster.git)
remote: Enumerating objects: 93, done.
remote: Counting objects: 100% (93/93), done.
...
```
It will be installed in `~/.mix/escripts`, so please add this path in your `$PATH`.

## Usage

At first, get your task identifier and IP address.

```bash
$ export ONESELF=`ecs_erlang_cluster oneself`
```

Second, generate `sys.config` file.

```bash
$ ecs_erlang_cluster generate \
  --cluster your_cluster_name \
  --service your_service_name \
  --region ap-northeast-1 \
  --minport 4370 \
  --maxport 4370

$ ls
sys.config
```

And you can run your elixir or erlang process.

```bash
$ iex --name $ONESELF --erl "-config sys.config" -S mix
```

## Note
### Fargate support
Now this command supports only EC2 type, not Fargate. And it doesn't support awsvpc as network mode. It supports only bridge.

### Port mapping
When you use this command, you should pay attention to port mapping of ECS task.
ErlangVM use two type port to connect other VM.

1. epmd port: 4369
2. connection port: random

First, you can not change epmd port. So you have to define port mapping for epmd port.

Second, connection port is random, but you can specify in `sys.config`. So `ecs_erlang_cluster` can specify minport and maxport. You have to define port mapping same as min/max port; For example 4370.


In conclusion, you should create following container definitions:

```json
[
  {
    "name": "container-name",
    "image": "elixir",
    "portMappings": [
      {
        "containerPort": 4369,
        "hostPort": 4369,
        "protocol": "tcp"
      },
      {
        "containerPort": 4369,
        "hostPort": 4369,
        "protocol": "udp"
      },
      {
        "containerPort": 4370,
        "hostPort": 4370,
        "protocol": "tcp"
      },
      {
        "containerPort": 4370,
        "hostPort": 4370,
        "protocol": "udp"
      }
    ],
    ...
  }
]
```

You don't use dynamic port mapping, because epmd can not manage dynamic port mapping.

### IAM Policy
Please prepare IAM policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:ListTasks",
        "ecs:DescribeTasks",
        "ecs:DescribeContainerInstances",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

And attach this to your task IAM Role.



## License

The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
