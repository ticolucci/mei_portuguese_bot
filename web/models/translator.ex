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
    case MeiPortugueseBot.Cache.lookup(:token) do
      false -> fetch_new_token
      token -> case valid_token(token) do
        true -> token
        _ -> fetch_new_token
      end
    end
  end

  def valid_token(token) do
    now_in_secs < token.expires_in - 10
  end

  def fetch_new_token do
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
    http_token = Poison.decode!(response.body, as: MeiPortugueseBot.Token)
    {expires_in_integer, _} = Integer.parse(http_token.expires_in)
    expires_in = now_in_secs + expires_in_integer
    token = %MeiPortugueseBot.Token{access_token: http_token.access_token, expires_in: expires_in}
    MeiPortugueseBot.Cache.add(:token, token)
    token
  end

  def now_in_secs do
    {_, secs, _} = :os.timestamp
    secs
  end

end
