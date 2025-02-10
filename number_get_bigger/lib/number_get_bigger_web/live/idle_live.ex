defmodule NumberGetBiggerWeb.IdleLive do
  use NumberGetBiggerWeb, :live_view

  defp auto_clicker_cost(), do: 100 # points
  defp tick_frequency(), do: 1000 # milliseconds

  def mount(_params, _session, socket) do
	  Process.send_after(self(), :tick, tick_frequency())
    socket =
      socket
      |> assign(%{points: 0, auto_clickers: 0, auto_clicker_cost: 100})

    {:ok, socket}
  end

  def render(assigns) do
    # TODO: refactor to separate document
    ~H"""
    <div>
      <p>Points: {@points}</p>
	    <p>Auto Clickers: {@auto_clickers}</p>
    </div>
    <br />
    <div>
      <.button id="manual_click" phx-click="manual_click">Make Number Bigger</.button>
    </div>
    <br />
    <div>
      <.button id="buy_auto_clicker" phx-click="buy_auto_clicker">
        Click for me ({@auto_clicker_cost} points)
      </.button>
    </div>
    """
  end

  def handle_event("manual_click", _params, socket) do
    socket =
      socket
      |> assign(:points, socket.assigns.points + 1)

    {:noreply, socket}
  end

  def handle_event("buy_auto_clicker", _params, socket) do
    if socket.assigns.points >= socket.assigns.auto_clicker_cost do
      socket =
        socket
        |> assign(%{
          points: socket.assigns.points - auto_clicker_cost(),
          auto_clickers: socket.assigns.auto_clickers + 1,
          auto_clicker_cost: round(socket.assigns.auto_clicker_cost * 1.10)
        })

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:tick, socket) do
	  Process.send_after(self(), :tick, tick_frequency())
	  socket =
		  socket
		  |> assign(:points, socket.assigns.points + socket.assigns.auto_clickers)

	  {:noreply, socket}
  end
end
