defmodule MeiPortugueseBot.TranslatorTest do
  use MeiPortugueseBot.ModelCase, async: true

  alias MeiPortugueseBot.Translator
  import Mock

  setup_all do
    System.put_env("CLIENT_ID", "client_id")
    System.put_env("CLIENT_SECRET", "client_secret")
  end

  setup do
    {_, secs, _} = :os.timestamp
    token_json = "{\"access_token\":\"token\",\"expires_in\":\"300\"}"
    response = %HTTPoison.Response{body: token_json}
    {:ok, response_token: response, now_in_secs: secs}
  end

  test "now_in_secs returns timestamp in seconds", context do
    assert(Translator.now_in_secs == context[:now_in_secs])
  end

  test "fetch_new_token calls oauth API and returns the token", context do
    with_mock HTTPoison, [post: fn(_url, _opts) -> {:ok, context[:response_token]} end] do
      token = Translator.fetch_new_token
      assert(called(
        HTTPoison.post(
          MeiPortugueseBot.translator_configs[:auth_host],
          {:form, [{:client_id, System.get_env("CLIENT_ID")},
                   {:client_secret, System.get_env("CLIENT_SECRET")},
                   {:scope, 'http://api.microsofttranslator.com'},
                   {:grant_type, 'client_credentials'}]
          }
        )
      ))
      assert(token != nil)
    end
  end

  test "fetch_new_token caches the result", context do
    with_mock HTTPoison, [post: fn(_url, _opts) -> {:ok, context[:response_token]} end] do
      token = Translator.fetch_new_token
      assert(token != false) # lookup returns false for inexistent value
      assert(MeiPortugueseBot.Cache.lookup(:token) == token)
    end
  end
end
