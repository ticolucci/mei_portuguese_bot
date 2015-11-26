defmodule MeiPortugueseBot.Translator do

  def translate(from, to, text) do
    token = fetch_token
    {:ok, response} = HTTPoison.get(
      "http://api.microsofttranslator.com/v2/Http.svc/Translate",
      [{:Authorization, "Bearer " <> token.access_token}],
      [params: [from: from, to: to, text: text]]
    )
    [[_, translated]] = Regex.scan(~r/>([^<]+)</, response.body)
    translated
  end

  def fetch_token do
    client_id = System.get_env("CLIENT_ID")
    client_secret = System.get_env("CLIENT_SECRET")

    {:ok, response} = HTTPoison.post(
      "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13",
      {:form, [{:client_id, client_id},
               {:client_secret, client_secret},
               {:scope, 'http://api.microsofttranslator.com'},
               {:grant_type, 'client_credentials'}]
      }
    )

    Poison.decode!(response.body, as: MeiPortugueseBot.Token)
  end

end
