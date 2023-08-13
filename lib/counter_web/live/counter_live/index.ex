defmodule CounterWeb.CounterLive.Index do
  use CounterWeb, :live_view
  @topic "live"


  def mount(_session, _params, socket) do
    CounterWeb.Endpoint.subscribe(@topic) # subscribe to the channel
    {:ok, assign(socket, :val, 0)}
  end

  def handle_event("inc_balance", _value, socket) do
    new_state = update(socket, :val, &(&1 + 1))
    CounterWeb.Endpoint.broadcast_from(self(), @topic, "inc", new_state.assigns)
    {:noreply, new_state}
  end

  def handle_event("dec_balance", _, socket) do
    new_state = update(socket, :val, &(&1 - 1))
    CounterWeb.Endpoint.broadcast_from(self(), @topic, "dec", new_state.assigns)
    {:noreply, new_state}
  end

  def handle_info(msg, socket) do
    {:noreply, assign(socket, val: msg.payload.val)}
  end

end
