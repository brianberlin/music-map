defmodule App.Shows do
  import Ecto.Query

  alias App.Show
  alias App.Venues
  alias App.Venue
  alias App.Repo

  def todays_shows(query) do
    query
    |> where([show: s], s.datetime >= ^beginning_of_day_central_time())
    |> where([show: s], s.datetime <= ^end_of_day_central_time())
  end

  def delete_shows do
    Repo.delete_all(Show, [])
  end

  @spec insert_or_update(map()) :: {:error, Ecto.Changeset.t()} | {:ok, Show.t()}
  def insert_or_update(%{event_id: event_id, venue_slug: venue_slug} = attrs) do
    with %Venue{} = venue <- Venues.get_venue_by_slug(venue_slug),
          attrs <- Map.put(attrs, :venue_id, venue.id) do
      case get_show_by_event_id(event_id) do
        nil ->
          create_show(attrs)
        show ->
          update_show(show, attrs)
      end
    end
  end

  defp get_show_by_event_id(event_id) do
    Show
    |> where(event_id: ^event_id)
    |> Repo.one()
  end

  defp create_show(attrs) do
    %Show{}
    |> change_show(attrs)
    |> Repo.insert()
  end

  defp update_show(show, attrs) do
    show
    |> change_show(attrs)
    |> Repo.update()
  end

  defp change_show(show, attrs) do
    Show.changeset(show, attrs)
  end

  defp beginning_of_day_central_time do
    %{month: month, day: day, year: year} = Timex.now("America/Chicago")
    NaiveDateTime.from_erl!({{year, month, day}, {0, 0, 0}})
  end

  defp end_of_day_central_time do
    %{month: month, day: day, year: year} = Timex.now("America/Chicago")
    NaiveDateTime.from_erl!({{year, month, day}, {23, 59, 59}})
  end
end
