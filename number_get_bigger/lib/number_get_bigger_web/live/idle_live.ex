defmodule NumberGetBiggerWeb.IdleLive do
  use NumberGetBiggerWeb, :live_view

  # milliseconds
  defp tick_frequency(), do: 1000

  def mount(_params, _session, socket) do
    Process.send_after(self(), :tick, tick_frequency())

    socket =
      socket
      |> assign(%{
        points: 0,
        auto_clickers: 0,
        auto_clicker_cost: 50,
        auto_clicker_mult: 1,
        auto_clicker_mult_cost: 1000
      })

    {:ok, socket}
  end

  def render(assigns) do
    # TODO: refactor to separate document
    ~H"""
    <div>
      <%= if @points > 0 || @auto_clickers > 0 do %>
        <p>Points: {@points}</p>
      <% end %>
      <%= if @auto_clickers > 0 do %>
        <p>Auto Clickers: {@auto_clickers}</p>
      <% end %>
      <%= if @auto_clicker_mult > 1 do %>
        <p>Auto Clicker Mult: {Float.round(@auto_clicker_mult, 2)}</p>
      <% end %>
    </div>
    <br />
    <div>
      <.button class="bg-emerald-900 hover:bg-emerald-700" id="manual_click" phx-click="manual_click">
        <%= if @points > 0 do %>
          Make Number Bigger
        <% else %>
          Make Number Bigger?
        <% end %>
      </.button>
    </div>
    <br />
    <div>
      <%= if @points >= @auto_clicker_cost do %>
        <.button
          class="bg-emerald-900 hover:bg-emerald-700"
          id="buy_auto_clicker"
          phx-click="buy_auto_clicker"
        >
          Do it for me ({@auto_clicker_cost} points)
        </.button>
      <% else %>
        <%= if @auto_clickers >= 1 do %>
          <.button id="buy_auto_clicker" phx-click="buy_auto_clicker" disabled>
            Do it for me ({@auto_clicker_cost} points)
          </.button>
        <% end %>
      <% end %>
    </div>
    <br />
    <div>
      <%= if @points >= @auto_clicker_mult_cost do %>
        <.button
          class="bg-emerald-900 hover:bg-emerald-700"
          id="upgrade_auto_clickers"
          phx-click="upgrade_auto_clickers"
        >
          Upgrade Auto Clickers ({@auto_clicker_mult_cost} points)
        </.button>
      <% else %>
        <%= if @auto_clicker_mult > 1 do %>
          <.button id="upgrade_auto_clickers" phx-click="upgrade_auto_clickers" disabled>
            Upgrade Auto Clickers ({@auto_clicker_mult_cost} points)
          </.button>
        <% end %>
      <% end %>
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
          points: socket.assigns.points - socket.assigns.auto_clicker_cost,
          auto_clickers: socket.assigns.auto_clickers + 1,
          auto_clicker_cost: round(socket.assigns.auto_clicker_cost * 1.10)
        })

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("upgrade_auto_clickers", _params, socket) do
    if socket.assigns.points >= socket.assigns.auto_clicker_mult_cost do
      socket =
        socket
        |> assign(%{
          points: socket.assigns.points - socket.assigns.auto_clicker_mult_cost,
          auto_clicker_mult: socket.assigns.auto_clicker_mult * 1.05,
          auto_clicker_mult_cost: round(socket.assigns.auto_clicker_mult_cost * 1.10)
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
      |> assign(
        :points,
        socket.assigns.points +
          round(socket.assigns.auto_clickers * socket.assigns.auto_clicker_mult)
      )

    {:noreply, socket}
  end
end
