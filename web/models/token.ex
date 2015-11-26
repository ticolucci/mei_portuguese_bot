defmodule MeiPortugueseBot.Token do
  @derive [Poison.Encoder]
  defstruct [:access_token, :expires_in]
end
