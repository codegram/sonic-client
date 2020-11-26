defmodule SonicClient.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :sonic_client,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:connection, "~> 1.1.0"}
    ]
  end

  defp description do
    """
    Client for Sonic which is a schema-less search backend.
    As it still in beta it shouldn't be used in production yet.
    """
  end

  defp docs do
    [
      source_url: "https://codegram.github.io/sonic-client/",
      source_ref: "v#{@version}",
      main: SonicClient
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/codegram/sonic-client"}
    }
  end
end
