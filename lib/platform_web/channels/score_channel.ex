defmodule PlatformWeb.ScoreChannel do
  @moduledoc """
    Score interaction channel
  """
  use PlatformWeb, :channel

  def join("score:platformer", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("save_score", payload, socket) do
    broadcast(socket, "save_score", payload)
    {:noreply, socket}
  end
end
