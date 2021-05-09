defmodule App.Venues do
  import Ecto.Query

  alias App.Venue
  alias App.Repo

  @spec insert_or_update(map()) :: {:error, Ecto.Changeset.t()} | {:ok, Venue.t()}
  def insert_or_update(%{slug: slug} = attrs) do
    case get_venue_by_slug(slug) do
      nil ->
        create_venue(attrs)
      venue ->
        update_venue(venue, attrs)
    end
  end

  def get_venue_by_slug(slug) do
    Venue
    |> where(slug: ^slug)
    |> Repo.one()
  end

  defp create_venue(attrs) do
    %Venue{}
    |> change_venue(attrs)
    |> Repo.insert()
  end

  defp update_venue(venue, attrs) do
    venue
    |> change_venue(attrs)
    |> Repo.update()
  end

  defp change_venue(venue, attrs) do
    Venue.changeset(venue, attrs)
  end
end
