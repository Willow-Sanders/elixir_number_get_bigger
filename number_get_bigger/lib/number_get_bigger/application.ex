defmodule NumberGetBigger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NumberGetBiggerWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:number_get_bigger, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NumberGetBigger.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: NumberGetBigger.Finch},
      # Start a worker by calling: NumberGetBigger.Worker.start_link(arg)
      # {NumberGetBigger.Worker, arg},
      # Start to serve requests, typically the last entry
      NumberGetBiggerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NumberGetBigger.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NumberGetBiggerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
