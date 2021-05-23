defmodule AppWeb.MapChannel do
  use Phoenix.Channel

  alias App.Venues

  def join("map", _message, socket) do
    {:ok, Venues.list_venues(), socket}
  end
end
