defmodule App.Crawlers.LivewireTest do
  use App.DataCase

  test "parse" do
    assert %{
      venues: [%{} | _],
      shows: [%{} | _]
    } = App.Crawlers.Livewire.parse()
  end
end
