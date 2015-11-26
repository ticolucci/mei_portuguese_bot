defmodule MeiPortugueseBot.PageController do
  use MeiPortugueseBot.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
