# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :mei_portuguese_bot, MeiPortugueseBot.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "aut1Mi5r7XM61jzXR1wXomlhgWyV2E02qJZaLXl0XBy5NdYZPzN1Er6UApRdxNsL",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: MeiPortugueseBot.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :mei_portuguese_bot, :translator,
  auth_host: "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13",
  translate_host: "http://api.microsofttranslator.com/v2/Http.svc/Translate"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
