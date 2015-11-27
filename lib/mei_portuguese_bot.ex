defmodule MeiPortugueseBot do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(MeiPortugueseBot.Endpoint, []),
      # Start the Ecto repository
      worker(MeiPortugueseBot.Repo, []),
      worker(MeiPortugueseBot.Cache, [])
      # Here you could define other workers and supervisors as children
      # worker(MeiPortugueseBot.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MeiPortugueseBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MeiPortugueseBot.Endpoint.config_change(changed, removed)
    :ok
  end

  def translator_configs do
    %{
      auth_host: "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13",
      translate_host: "http://api.microsofttranslator.com/v2/Http.svc/Translate"
    }
  end
end
