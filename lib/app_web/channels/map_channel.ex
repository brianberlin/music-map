defmodule AppWeb.MapChannel do
  use Phoenix.Channel

  alias App.Venues

  def join("map", _message, socket) do
    App.Crawlers.Livewire.subscribe()
    {:ok, Venues.list_venues(), socket}
  end

  def handle_info({:venues, venues}, socket) do
    push(socket, "venues", %{venues: venues})
    {:noreply, socket}
  end
end
