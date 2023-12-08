defmodule GithubUserSearchApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GithubUserSearchAppWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:github_user_search_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GithubUserSearchApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GithubUserSearchApp.Finch},
      # Start a worker by calling: GithubUserSearchApp.Worker.start_link(arg)
      # {GithubUserSearchApp.Worker, arg},
      # Start to serve requests, typically the last entry
      GithubUserSearchAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GithubUserSearchApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GithubUserSearchAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
