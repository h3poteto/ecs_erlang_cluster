defmodule Ec2Mock do
  use Trot.Router

  get "/latest/meta-data/local-ipv4" do
    "192.186.0.1"
  end

  import_routes Trot.NotFound
end
