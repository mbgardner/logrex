defmodule Logrex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :logrex,
      version: "0.4.2",
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/mbgardner/logrex"
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
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Logging for humans."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Matthew B Gardner"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mbgardner/logrex"}
    ]
  end
end
