defmodule App.Repo.Migrations.VenuesAndShows do
  use Ecto.Migration

  def change do
    execute(
      "CREATE EXTENSION IF NOT EXISTS postgis",
      "DROP EXTENSION IF EXISTS postgis"
    )

    create table("venues") do
      add :slug, :string
      add :name, :string
      add :address, :string
      add :city, :string
      add :phone, :string
      add :state, :string
      add :web_address, :string
      add :zip, :string

      timestamps()
    end

    create table("shows") do
      add :name, :string
      add :datetime, :naive_datetime
      add :event_id, :string
      add :venue_id, references(:venues)

      timestamps()
    end

    create index("venues", [:slug])
  end
end
