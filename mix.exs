defmodule Mnemo.MixProject do
  use Mix.Project

  @version "0.1.3"
  @source_url "https://github.com/aerosol/mnemo"

  def project do
    [
      app: :mnemo,
      deps: deps(),
      description: "BIP39 Mnemonics",
      docs: docs(),
      elixir: "~> 1.8",
      package: package(),
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.16", only: :dev},
      {:jason, "~> 1.1"},
      {:pbkdf2_elixir, "~> 1.1"}
    ]
  end

  defp docs do
    [
      source_ref: "#{@version}",
      source_url: @source_url,
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      maintainers: ["Adam Rutkowski"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
