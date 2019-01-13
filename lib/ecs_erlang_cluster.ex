defmodule EcsErlangCluster do
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(
      argv,
      switches: [help: :boolean, version: :boolean, file: :string, cluster: :string, service: :string, region: :string],
      aliases: [h: :help, f: :file, c: :cluster, s: :service]
    )

    case parse do
      { [ help: true ], _, _ }
        -> :help
      { [ version: true ], _, _ }
        -> :version
      { opts, message, _ }
        -> case message do
             ["oneself" | other] -> {:oneself, opts, other}
             ["generate" | other] -> {:generate, opts, other}
             ["help" | _other] -> :help
             ["version" | _other] -> :version
             _ -> message
           end
    end
  end

  def process(:help) do
    IO.puts """
    Usage: ecs_erlang_cluster <command>
    """
    System.halt(0)
  end

  def process(:version) do
    IO.puts """
    0.1.0
    """
    System.halt(0)
  end

  def process({:oneself, _opts, _other}) do
    mes = EcsErlangCluster.Oneself.get()
    IO.puts mes
    System.halt(0)
  end

  def process({:generate, opts, _other}) do
    map_opts = opts |> Enum.into(%{})
    cluster = cluster_name_parse(map_opts)
    service = service_name_parse(map_opts)
    region = region_parse(map_opts)
    IO.puts "Cluster name: #{cluster}"
    IO.puts "Service name: #{service}"
    file_name = map_opts
    |> file_parse
    EcsErlangCluster.Generate.run(cluster, service, file_name, region)
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
end
