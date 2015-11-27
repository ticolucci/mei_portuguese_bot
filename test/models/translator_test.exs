defmodule MeiPortugueseBot.TranslatorTest do
  use MeiPortugueseBot.ModelCase, async: true

  alias MeiPortugueseBot.Translator
  alias MeiPortugueseBot.Cache
  alias MeiPortugueseBot.Token
  import Mock

  @config Application.get_env(:mei_portuguese_bot, :translator)

  setup_all do
    System.put_env("CLIENT_ID", "client_id")
    System.put_env("CLIENT_SECRET", "client_secret")
  end

  setup do
    Cache.delete(:token)
    {_, secs, _} = :os.timestamp
    token_json = "{\"access_token\":\"new_token\",\"expires_in\":\"300\"}"
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
          @config[:auth_host],
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
      assert(Cache.lookup(:token) == token)
    end
  end

  test "fetch_token without a token, calls fetch_new_token and returns the token", context do
    assert(Cache.lookup(:token) == false)
    with_mock HTTPoison, [post: fn(_url, _opts) -> {:ok, context[:response_token]} end] do
      token = Translator.fetch_token
      assert(token != nil)
      assert(token.access_token == "new_token")
    end
  end

  test "fetch_token with a valid cached token, returns the cached value", context do
    expires_in = context[:now_in_secs] + 300
    token = %Token{access_token: "cached", expires_in: expires_in}
    Cache.add(:token, token)

    with_mock HTTPoison, [post: fn(_url, _opts) -> {:ok, context[:response_token]} end] do
      token = Translator.fetch_token
      assert(token != nil)
      assert(token.access_token == "cached")
    end
  end

  test "fetch_token with a invalid cached token, returns a new token", context do
    expires_in = context[:now_in_secs] - 300
    token = %Token{access_token: "cached", expires_in: expires_in}
    Cache.add(:token, token)

    with_mock HTTPoison, [post: fn(_url, _opts) -> {:ok, context[:response_token]} end] do
      token = Translator.fetch_token
      assert(token != nil)
      assert(token.access_token == "new_token")
    end
  end
end
