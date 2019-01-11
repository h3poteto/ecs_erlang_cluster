use Mix.Config

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: "ap-northeast-1"

config :metadata_endpoint,
  ecs: System.get_env("ECS_CONTAINER_METADATA_URI"),
  ec2: System.get_env("EC2_METADATA_URI")
