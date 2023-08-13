# Counter

This is a step by step tutorial of how to create a counter using liveview and sharing state with all the clients

```sh
mix phx.new counter --no-dashboard --no-gettext --no-mailer –no-ecto
```


# Then we will create the structure for the counter component: 

lib  |counter
     | counter_web  |components
                    |controllers
                    |live           |counter_live   |index.ex
                                                    |index.html.heex


Create two new file with the path: 
    /lib/counter_web/live/counter_live/index.ex
    /lib/counter_web/live/counter/index.html.heex

the counter.ex: will need to have at least the mount function, but also will handle the events from the html template

We will start by creating the html with a main counter and two bottoms oone for incrementing the counter and one for decreasing the counter.

then we will add the event on the buttons and create the events handelers in the controller. we will implement increment and decrease of the counter

And finaly we will share the state of the counter with all the clinets and we will subscribe them to. 



Lets add the following into the /lib/counter_web/live/counter.html.heex

```html
<.header>
  This is a counter
</.header>


<h1>The count is: <%= @val %> </h1>

<.button">increase balance</.button>
<.button>Decrease balances</.button>
```

However we need the controller to be able to visualize the "view"

Lets add the following code to the file with the path: /lib/counter_web/live/counter.ex

```phx
defmodule CounterWeb.CounterLive.Index do
  use CounterWeb, :live_view
  @topic "live"


  def mount(_session, _params, socket) do
    CounterWeb.Endpoint.subscribe(@topic) # subscribe to the channel
    {:ok, assign(socket, :val, 0)}
  end


end

```

lets not forget to include the new route in the router
```sh
live "/", CounterLive.Index, :index
```


at this point lets start the server and lets check that we can see the counter: 

```phx
mix phx.server
```



so now we can see that when we go to the url / we see the counter and thw buttons, but nothing happen when we pressed them!

Lets go and generate the phoenix evenats and the events handelers: 

lets go to the index.html.heex file and lets update the buttons; 

```phx

<.button phx-click="inc_balance">increase balance</.button>
<.button phx-click="dec_balance">Decrease balances</.button>
```

now if from the browser we click the buttons we gonna see that it gives as a error. Lets go and implement the event handelers

open the file index.ex and 

```phx
defmodule CounterWeb.CounterLive.Index do
  use CounterWeb, :live_view


  def mount(_session, _params, socket) do
    {:ok, assign(socket, :val, 0)}
  end


  def handle_event("inc_balance", _value, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec_balance", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

end

```

At this point the counter is functional and buttons increase and decrease the value of the counter Howeve if we have multiple browsers open we will see that the value is not share betwen our clients. 

If we want to see in real time one counter to change when from another brtowser the counter is increased or decreased, we need to share state with all the clients to so some we need to update our controller: 


```phx
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


```

