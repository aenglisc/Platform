defmodule Platform.Products.Gameplay do
  use Ecto.Schema
  import Ecto.Changeset
  alias Platform.Accounts.Player
  alias Platform.Products.Game


  schema "gameplays" do
    belongs_to :player, Player
    belongs_to :game, Game
    field :player_score, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(gameplay, attrs) do
    gameplay
    |> cast(attrs, [:player_score])
    |> validate_required([:player_score])
  end
end
