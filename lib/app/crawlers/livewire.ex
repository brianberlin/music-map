defmodule App.Crawlers.LivewireTest do
  use GenServer

  @url "https://www.wwoz.org/calendar/livewire-music"
  @interval 10_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, [], {:continue, :crawl}}
  end

  def handle_continue(:crawl, state) do
    %{body: body} = Req.get!(@url)
    File.write("livewire.html", body)

    Process.sleep(10_000)
    {:noreply, state, {:continue, :crawl}}
  end

  def parse do
    {:ok, html} = File.read("livewire.html")
    {:ok, document} = Floki.parse_document(html)
    [listings] = Floki.find(document, ".livewire-listing")
    Floki.find(listings, "div.panel-default")
  end
end
