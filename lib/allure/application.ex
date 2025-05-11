defmodule Allure.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AllureWeb.Telemetry,
      Allure.Repo,
      {DNSCluster, query: Application.get_env(:allure, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Allure.PubSub},
      # Start a worker by calling: Allure.Worker.start_link(arg)
      # {Allure.Worker, arg},
      # Start to serve requests, typically the last entry
      AllureWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Allure.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AllureWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
