defmodule EcsErlangCluster do
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(
      argv,
      switches: [help: :boolean, version: :boolean, file: :string, cluster: :string, service: :string, region: :string, minport: :integer, maxport: :integer],
      aliases: [h: :help, f: :file, c: :cluster, s: :service]
    )

    case parse do
      { opts, ["oneself" | other], _ }
        -> {:oneself, opts, other}
      { opts, ["generate" | other], _ }
        -> {:generate, opts, other}
      { _opts, ["help" | _other], _ }
        -> :help
      { _opts, ["version" | _other], _ }
        -> :version
      { [help: true], _, _ }
        -> :help
      { [version: true], _, _ }
        -> :version
      { _opts, message, _ }
        -> message
    end
  end

  def process(:help) do
    IO.puts """
    ECS Erlang Cluster

    Usage: ecs_erlang_cluster <command>

    Commands:
      oneself      Get own task ID and private IP address of EC2 instance
      generate     Generate sys.config file
      help         Show this help
      version      Print the version number

    Flags:
      -h, --help      Show this help
      -v, --version   Print the version number
    """
    System.halt(0)
  end

  def process(:version) do
    IO.puts """
    0.1.0
    """
    System.halt(0)
  end

  def process({:oneself, [help: true], _other}) do
    IO.puts """
    Get own task ID and private IP address of EC2 instance.

    Usage: ecs_erlang_cluster oneself [flags]

    Flags:
      -h, --help      Show this help
    """
    System.halt(0)
  end

  def process({:oneself, _opts, _other}) do
    mes = EcsErlangCluster.Oneself.get()
    IO.puts mes
    System.halt(0)
  end

  def process({:generate, [help: true], _other}) do
    IO.puts """
    Generate sys.config.

    Usage: ecs_erlang_cluster generate [flags]

    Flags:
      -h, --help      Show this help
      -f, --file      File name to output (default: sys.config)
      -c, --cluster   ECS Cluster name
      -s, --service   ECS Service name
      --region        AWS region name
      --minport       Min port number which is used to connect other ErlangVM
      --maxport       Max port number which is used to connect other ErlangVM
    """
    System.halt(0)
  end

  def process({:generate, opts, _other}) do
    map_opts = opts |> Enum.into(%{})
    cluster = cluster_name_parse(map_opts)
    service = service_name_parse(map_opts)
    region = region_parse(map_opts)
    min_port = min_port_parse(map_opts)
    max_port = max_port_parse(map_opts)
    IO.puts "Cluster name: #{cluster}"
    IO.puts "Service name: #{service}"
    file_name = map_opts
    |> file_parse
    EcsErlangCluster.Generate.run(cluster, service, file_name, region, min_port, max_port)
    IO.puts "Generated #{file_name}"
    System.halt(0)
  end

  def process(message) do
    IO.puts "Unknown options: #{message}"
    System.halt(1)
  end

  defp file_parse(%{file: file}) do
    file
  end

  defp file_parse(_) do
    "sys.config"
  end

  defp cluster_name_parse(%{cluster: cluster}) do
    cluster
  end

  defp cluster_name_parse(_) do
    IO.puts "Error: cluster name is required."
    System.halt(1)
  end

  defp service_name_parse(%{service: service}) do
    service
  end

  defp service_name_parse(_) do
    IO.puts "Error: service name is required"
    System.halt(1)
  end

  defp region_parse(%{region: region}) do
    region
  end

  defp region_parse(_) do
    IO.puts "Error: region is required"
    System.halt(1)
  end

  defp min_port_parse(%{minport: min_port}) do
    min_port
  end

  defp min_port_parse(_) do
    IO.puts "Error: min_port is required"
    System.halt(1)
  end

  defp max_port_parse(%{maxport: max_port}) do
    max_port
  end

  defp max_port_parse(_) do
    IO.puts "Error: max_port is required"
    System.halt(1)
  end
end
