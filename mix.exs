defmodule Bitcoin.MixProject do
  use Mix.Project

  def project do
    [
      app: :bitcoin,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :chumak],
      mod: {Bitcoin.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.10.2"},
      {:jason, "~> 1.2"},
      {:decimal, "~> 2.0"},
      {:chumak, "~> 1.4.0"},
      {:b58, "~> 1.0.2"},
    ]
  end
end
