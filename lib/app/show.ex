defmodule App.Show do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Venue

  @derive {Jason.Encoder, only: [:event_id, :name, :datetime]}
  schema "shows" do
    field :event_id, :string
    field :name, :string
    field :datetime, :utc_datetime

    belongs_to :venue, Venue

    timestamps()
  end

  def changeset(show \\ %__MODULE__{}, attrs) do
    show
    |> cast(attrs, [:name, :datetime, :event_id, :venue_id])
    |> cast_assoc(:venue)
  end
end
