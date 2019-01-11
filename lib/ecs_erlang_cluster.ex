defmodule EcsErlangCluster do
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(
      argv,
      switches: [help: :boolean, file: :string],
      aliases: [h: :help, f: :file]
    )

    case parse do
      { [ help: true ], _, _ }
        -> :help
      { opts, message, _ }
        -> case message do
             ["oneself" | other] -> {:oneself, opts, other}
             ["generate" | other] -> {:generate, opts, other}
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

  def process({:oneself, _opts, _other}) do
    mes = EcsErlangCluster.Oneself.get()
    IO.puts mes
    System.halt(0)
  end

  def process({:generate, opts, _other}) do
    file_name = opts
    |> file_parse
    EcsErlangCluster.Generate.run("scouty-service-stg", "scouty-service-stg", file_name)
    System.halt(0)
  end

  def process(message) do
    IO.puts "Unknown options: #{message}"
    System.halt(1)
  end

  defp file_parse(opts) do
    case opts do
      [file: file] -> file
      [f: file] -> file
      _ -> "sys.config"
    end
  end
end
