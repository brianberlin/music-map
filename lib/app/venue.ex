defmodule App.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "venues" do
    field :slug, :string
    field :name, :string
    field :address, :string
    field :city, :string
    field :phone, :string
    field :state, :string
    field :web_address, :string
    field :zip, :string
    field(:point, Geo.PostGIS.Geometry)

    timestamps()
  end

  def changeset(venue \\ %__MODULE__{}, attrs) do
    cast(venue, attrs, [:name, :address, :city, :phone, :state, :web_address, :zip, :slug, :point])
  end
end
