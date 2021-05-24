defmodule AppWeb.LiveViews.Page do
  use AppWeb, :surface_live_view

  def mount(_, _, socket) do
    {:ok, assign(socket, :venues, App.Venues.list_venues())}
  end

  def render(assigns) do
    ~H"""
      <x-map phx-update="ignore" class="absolute w-full h-full">
          <x-map-marker
            :for={{venue <- @venues}}
            name={{venue.name}}
            lat={{get(:lat, venue)}}
            lng={{get(:lon, venue)}}
            shows={{shows(venue)}}
          />
      </x-map>
    """
  end

  defp get(:lat, %{point: %{coordinates: {_, lat}}}), do: lat
  defp get(:lon, %{point: %{coordinates: {lon, _}}}), do: lon
  defp get(_, _), do: nil

  defp shows(%{shows: shows}) do
    shows
    |> Enum.map(fn %{name: name, datetime: datetime} ->
      """
      #{name} #{Timex.format!(datetime, "{h12}:{m} {am}")}
      """
    end)
    |> Enum.join("||")

  end
end
