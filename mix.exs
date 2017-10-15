defmodule Logrex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :logrex,
      version: "0.1.0",
      elixir: "~> 1.5",
      description: description(),
      package: package(),
      start_permanent: Mix.env == :prod,
      deps: deps()
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
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A log formatter for displaying dynamic metadata fields."
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Matthew B Gardner"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mbgardner/logrex"}
    ]
  end
end
