defmodule PlatformWeb.PlayerApiView do
  use PlatformWeb, :view

  def render("index.json", %{players: players}) do
    %{data: render_many(players, __MODULE__, "player.json")}
  end

  def render("show.json", %{player: player}) do
    %{data: render_one(player, __MODULE__, "player.json")}
  end

  def render("player.json", %{player_api: player_api}) do
    %{
      id: player_api.id,
      username: player_api.username,
      display_name: player_api.display_name,
      score: player_api.score
    }
  end
end