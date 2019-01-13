use Mix.Config

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :metadata_endpoint,
  ecs: {:system, "ECS_CONTAINER_METADATA_URI"},
  ec2: {:system, "EC2_METADATA_URI"}
