defmodule App.Repo.Migrations.AddVenuePoint do
  use Ecto.Migration

  def change do
    alter table(:venues) do
      add(:point, :geometry)
    end
  end
end
