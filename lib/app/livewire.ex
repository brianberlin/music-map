defmodule App.Crawlers.Livewire do
  use GenServer

  alias App.Venues
  alias App.Shows

  @base_url "https://www.wwoz.org"

  def subscribe do
    Phoenix.PubSub.subscribe(App.PubSub, "shows")
  end

  def broadcast do
    Phoenix.PubSub.broadcast!(App.PubSub, "shows", {:venues, Venues.list_venues()})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_) do
    {:ok, %{}, {:continue, :fetch_calendar}}
  end

  def handle_continue(:fetch_calendar, state) do
    {:noreply, state, {:continue, {:parse_events_and_venues, fetch_and_parse("/calendar/livewire-music")}}}
  end

  def handle_continue({:parse_events_and_venues, document}, _state) do
    state =
      document
      |> Floki.find(".livewire-listing > div > div.panel-default")
      |> Enum.reduce(%{shows: [], venues: []}, fn venue, data ->
        data
        |> Map.put(:shows, data.shows ++ get_shows(venue))
        |> Map.put(:venues, data.venues ++ [get_venue(venue)])
      end)

    {:noreply, state, {:continue, :fetch_venue_data}}
  end

  def handle_continue(:fetch_venue_data, state) do
    venue_index = Enum.find_index(state.venues, & !&1.processed)

    if is_nil(venue_index) do
      {:noreply, state, {:continue, :save_to_database}}
    else
      venues = List.update_at(state.venues, venue_index, &update_venue/1)
      state = Map.put(state, :venues, venues)

      {:noreply, state, {:continue, :fetch_venue_data}}
    end
  end

  def handle_continue(:save_to_database, %{shows: shows, venues: venues}) do
    Enum.each(venues, &Venues.insert_or_update/1)
    Enum.each(shows, &Shows.insert_or_update/1)
    broadcast()
    {:noreply, %{}, {:continue, :wait_and_restart}}
  end

  def handle_continue(:wait_and_restart, _state) do
    Process.sleep(1000 * 60 * 15)
    {:noreply, %{}, {:continue, :fetch_calendar}}
  end

  defp get_shows(venue) do
    anchor = Floki.find(venue, ".panel-title a")
    ["/organizations/" <> venue_slug] = Floki.attribute(anchor, "href")
    rows = Floki.find(venue, ".panel-body .row")

    Enum.map(rows, fn row ->
      anchor = Floki.find(row, "p > a")
      ["/events/" <> event_id] = Floki.attribute(anchor, "href")
      name = Floki.text(anchor) |> String.trim()
      datetime_string = Floki.find(row, "p:nth-child(2)") |> Floki.text() |> String.replace(~r/\s+/, " ") |> String.trim()
      with_year = Timex.format!(Timex.now(), "{YYYY}") <> " " <> datetime_string
      datetime = Timex.parse!(with_year, "{YYYY} {WDfull}, {Mshort} {D} at {h12}:{m}{am}")

      %{
        event_id: event_id,
        name: name,
        venue_slug: venue_slug,
        datetime: datetime
      }
    end)
  end

  defp get_venue(venue) do
    anchor = Floki.find(venue, ".panel-title a")
    name = anchor |> Floki.text() |> String.trim()
    ["/organizations/" <> slug] = Floki.attribute(anchor, "href")

    %{
      name: name,
      slug: slug,
      processed: false,
    }
  end

  def update_venue(venue) do
    document = fetch_and_parse("/organizations/" <> venue.slug)
    address_el = Floki.find(document, ".content")

    address_parts = [
      {:city, ".locality"},
      {:zip, ".postal-code"},
      {:address, ".thoroughfare"},
      {:state, ".state"},
      {:phone, ".field-type-telephone .field-item"},
      {:web_address, ".field-type-link-field"}
    ]

    address =
      Enum.reduce(address_parts, %{}, fn {key, class}, address ->
        value = Floki.find(address_el, class) |> Floki.text() |> String.trim
        Map.put(address, key, value)
      end)

    venue
    |> Map.merge(address)
    |> Map.merge(geocode_address(address))
    |> Map.put(:processed, true)
  end

  defp fetch_and_parse(path) do
    with %{body: body} <- Req.get!(@base_url <> path, retry: true),
         {:ok, document} <- Floki.parse_document(body) do
      Process.sleep(1_000)
      document
    end
  end

  def geocode_address(%{address: ""}), do: %{}

  def geocode_address(%{address: address, city: city, state: state, zip: zip}) do
    address = String.replace(address, " " , "+")
    city = String.replace(city, " ", "+")
    state = String.replace(state, " ", "+")
    host = Application.get_env(:app, :nominatim_host)
    IO.inspect("#{host}/search?q=#{address}+#{city}+#{state}+#{zip}&format=json")
    %{body: body} = Req.get!("#{host}/search?q=#{address}+#{city}+#{state}+#{zip}&format=json")

    case body do
      [%{"lat" => lat, "lon" => lon} | _] ->
        {lon, _} = Float.parse(lon)
        {lat, _} = Float.parse(lat)
        %{point: %Geo.Point{coordinates: {lon, lat}, srid: 4326}}

      _ ->
        %{}
    end
  end
end
