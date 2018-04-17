defmodule PlatformWeb.ScoreChannel do
  @moduledoc """
    Score interaction channel
  """
  use PlatformWeb, :channel
  alias Platform.Products

  def join("score:" <> game_slug, _payload, socket) do
    game = Products.get_game_by_slug!(game_slug)
    socket = assign(socket, :game_id, game.id)
    {:ok, socket}
  end

  def handle_in("save_score", %{"player_score" => player_score} = _payload, socket) do
    new_payload = %{
      player_score: player_score,
      game_id: socket.assigns.game_id,
      player_id: socket.assigns.player_id
    }

    Products.create_gameplay(new_payload)
    broadcast(socket, "save_score", new_payload)
    {:noreply, socket}
  end
end
