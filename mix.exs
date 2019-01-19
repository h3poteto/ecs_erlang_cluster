defmodule EcsErlangCluster.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecs_erlang_cluster,
      version: "0.1.0",
      elixir: "~> 1.7",
      escript: [main_module: EcsErlangCluster],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "This is a command line tool to create the Erlang cluster on AWS ECS.",
      package: [
        maintainers: ["h3poteto"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/h3poteto/ecs_erlang_cluster"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.5.0"},
      {:poison, "~> 3.1"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_ec2, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:ex_aws_ecs, github: "Upptec/ex_aws_ecs"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
