defmodule DatomicGenServer.Mixfile do
  use Mix.Project

  def project do
    [app: :datomic_gen_server,
     version: "1.0.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :calendar]] # Calendar needed for edn conversions of #inst
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [ {:exdn,    "~> 2.1.1"},
      {:dialyxir, "~> 0.3", only: [:dev]}]
  end
end
