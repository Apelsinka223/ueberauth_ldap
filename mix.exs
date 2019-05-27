defmodule UeberauthLdap.MixProject do
  use Mix.Project

  def project do
    [
      app: :ueberauth_ldap,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.0"},
      {:ueberauth, "~> 0.6"},
      {:exldap, "~> 0.6"},

      # dev/test dependencies
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.20", only: :dev},
      {:mox, "~> 0.5", only: :test}
    ]
  end
end
