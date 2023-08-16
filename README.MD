This tutorial is a step-by-step guide to creating a real-time counter using Phoenix LiveView. It.s based on the tutorial https://github.com/dwyl/phoenix-todo-list-tutorial . It demonstrates how to share state between clients and synchronize updates in real-time. Here's a summarized and interpreted version of the tutorial:

# Creating the Phoenix Application
Create a new Phoenix application named "counter" without certain components using the following command:

```sh
mix phx.new counter --no-dashboard --no-gettext --no-mailer --no-ecto
```

Create the necessary files and folders for the counter component structure:

Create the folder structure: lib/counter/counter_web/components/live/counter_live
Inside this directory, create two files:
index.ex (for the LiveView module)
index.html.heex (for the LiveView template)

Creating the Counter Component
Define the LiveView module in index.ex:

```Sh
defmodule CounterWeb.CounterLive.Index do
  use CounterWeb, :live_view
  @topic "live"

  def mount(_session, _params, socket) do
    CounterWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, :val, 0)}
  end
end
```

Update the LiveView template index.html.heex:

```html

<.header>
  This is a counter
</.header>

<h1>The count is: <%= @val %> </h1>

<.button phx-click="inc_balance">increase balance</.button>
<.button phx-click="dec_balance">Decrease balances</.button>
```

# Handling Events
Update the LiveView module in index.ex to handle events:

```elixir
defmodule CounterWeb.CounterLive.Index do
  use CounterWeb, :live_view

  # ...

  def handle_event("inc_balance", _value, socket) do
    new_state = update(socket, :val, &(&1 + 1))
    {:noreply, new_state}
  end

  def handle_event("dec_balance", _, socket) do
    new_state = update(socket, :val, &(&1 - 1))
    {:noreply, new_state}
  end
end
```

# Sharing State with Clients
Update the LiveView module in index.ex to broadcast state changes:

```elixir
defmodule CounterWeb.CounterLive.Index do
  use CounterWeb, :live_view
  @topic "live"

  # ...

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
end
```

Implement an handle_info callback in the LiveView module to handle broadcasted updates:

```elixir
defmodule CounterWeb.CounterLive.Index do
  use CounterWeb, :live_view
  @topic "live"

  # ...

  def handle_info(%Phoenix.Socket.Broadcast{event: "inc", payload: %{assigns: %{val: new_val}}}, socket) do
    {:noreply, assign(socket, val: new_val)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "dec", payload: %{assigns: %{val: new_val}}}, socket) do
    {:noreply, assign(socket, val: new_val)}
  end
end
```

# Final Steps
Add the new route in the router to point to the LiveView:

```elixir
Copy code
live "/", CounterLive.Index, :index
Start the Phoenix server:
```
```sh
Copy code
mix phx.server
```

This tutorial guides you through creating a real-time counter application using Phoenix LiveView. It demonstrates how to share state between clients and keep the counter in sync across different browsers.