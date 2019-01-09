defmodule EcsErlangCluster do
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(
      argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )

    case parse do
      { [ help: true ], _, _ }
        -> :help
      { opts, message, _ }
        -> case message do
             ["oneself" | other] -> {:oneself, opts, other}
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

  def process({:oneself, opts, other}) do
    EcsErlangCluster.Oneself.get()
    System.halt(0)
  end

  def process(message) do
    IO.puts "Unknown options: #{message}"
    System.halt(1)
  end
end
