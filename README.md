# Alice [![Hex Version](https://img.shields.io/hexpm/v/alice.svg)](https://hex.pm/packages/alice) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/alice-bot/alice.svg)](https://beta.hexfaktor.org/github/alice-bot/alice) [![Hex Downloads](https://img.shields.io/hexpm/dt/alice.svg)](https://hex.pm/packages/alice) [![License: MIT](https://img.shields.io/hexpm/l/alice.svg)](https://hex.pm/packages/alice)

#### A Lita-inspired Slack bot written in Elixir.

<img height="135" src="http://i.imgur.com/UndMkm3.png" align="left" />

_The Caterpillar and Alice looked at each other for some time in silence: at
last the Caterpillar took the hookah out of its mouth, and addressed her in a
languid, sleepy voice._

_"Who are YOU?" said the Caterpillar. This was not an encouraging opening for
conversation. Alice replied, rather shyly, "I—I hardly know, sir, just at
present—at least I know who I WAS when I got up this morning, but I think I must
have been changed several times since then."_

Some breaking changes have been introduced in version [0.2.0]. Please see the
[wiki page] for more info.

__Anyone running Alice 0.3 or higher is highly encouraged to move to [0.3.6]
ASAP. Version [0.3.6] will save the state data in Redis as JSON, whereas the
previous versions were simply converting the elixir into a string. This had
some limitations, namely only supporting 50 key-value pairs before producing an
unparsable string with a "..." in it. Version [0.3.6] will also migrate your
existing state to use JSON, so there’s no going back after upgrading. This
change should not affect handler so it is not a breaking change.__

For an example bot, see the [Active Alice] bot. For an example
handler, see [Google Images Handler].

You'll need a Slack API token which can be retrieved from the [Web API page] or
by creating a new [bot integration].

[0.2.0]: https://hex.pm/packages/alice/0.2.0
[wiki page]: https://github.com/alice-bot/alice/wiki/Alice-0.2.0-Changes
[0.3.6]: https://hex.pm/packages/alice/0.3.6
[Active Alice]: https://github.com/adamzaninovich/active-alice
[Google Images Handler]: https://github.com/alice-bot/alice_google_images

[Web API page]: https://api.slack.com/web
[bot integration]: https://my.slack.com/services/new/bot

## Handler Plugins

Alice has a plug in system that allows you to customize the functionality of
your bot instance. See [the docs] for more information about creating your own
handlers.

[the docs]: https://github.com/alice-bot/alice#creating-a-route-handler-plugin

### Known Handlers

* Alice Against Humanity: [hex](https://hex.pm/packages/alice_against_humanity), [code](https://github.com/alice-bot/alice_against_humanity)
* Alice Google Images: [hex](https://hex.pm/packages/alice_google_images), [code](https://github.com/alice-bot/alice_google_images)
* Alice Karma: [hex](https://hex.pm/packages/alice_karma), [code](https://github.com/alice-bot/alice_karma)
* Alice Reddit: [hex](https://hex.pm/packages/alice_reddit), [code](https://github.com/alice-bot/alice_reddit)
* Alice Shizzle: [hex](https://hex.pm/packages/alice_shizzle), [code](https://github.com/notdevinclark/alice_shizzle)
* Alice XKCD: [hex](https://hex.pm/packages/alice_xkcd), [code](https://github.com/notdevinclark/alice_xkcd)
* Alice Doge [hex](https://hex.pm/packages/alice_doge_me), [code](https://github.com/alice-bot/alice_doge_me/)

If you write your own handler, please submit a pull request and update this list!

## Creating Your Own Bot With Alice

### Create the Project

Create a new mix project.
```sh
mix new my_bot
cd my_bot
rm lib/my_bot.ex test/my_bot_test.exs
```

### Configure the Application

In `mix.exs`, bring in alice and any other handlers you want. You also need to
include the `websocket_client` dependency because it's not a [hex] package.
[hex]: http://hex.pm
```elixir
defp deps do
  [
    {:websocket_client, github: "jeremyong/websocket_client"},
    {:alice,                  "~> 0.2.0"},
    {:alice_against_humanity, "~> 0.1.0"},
    {:alice_google_images,    "~> 0.1.0"}
  ]
end
```

Add Alice to the list of applications to start.

[Writing Route Handlers]: https://github.com/alice-bot/alice#writing-route-handlers

```elixir
def application do
  [applications: [:alice]]
end
```

In `config/config.exs`, configure the app, registering the adapter and any
handlers you want. You can add handlers through dependencies, or you can
write them directly in your bot instance. (See [Writing Route Handlers]
for information on how to write a handler. We recommend putting them in
`lib/alice/handlers/`.)

Also add any extra configuration that your bot needs.

```elixir
use Mix.Config

config :alice,
  adapter: Alice.Adapters.Slack,
  slack: [key: System.get_env("SLACK_API_TOKEN")],
  handlers: [
    Alice.Handlers.Random,
    Alice.Handlers.AgainstHumanity,
    Alice.Handlers.GoogleImages
  ],
  state_backend: :redis,
  redis: System.get_env("REDIS_URL")

config :alice_google_images,
  cse_id: System.get_env("GOOGLE_CSE_ID"),
  cse_token: System.get_env("GOOGLE_CSE_TOKEN"),
  safe_search_level: :medium
```

With that, you're done! Run your bot with `iex -S mix` or `mix run --no-halt`.

If you want to run a console then use `mix alice.console`. (This will run the
console even if you have a different adapter configured.)

### Deploying to Heroku

Create a new heroku app running Elixir.
```sh
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
```

Create a file called `heroku_buildpack.config` at the root of your project.
```sh
erlang_version=18.2.1
elixir_version=1.2.1
always_rebuild=false

post_compile="pwd"
```

Create a `Procfile` at the root of your project. If you don't create the proc
as a `worker`, Heroku will assume it's a web process and will terminate it for
not binding to port 80.
```ruby
worker: mix run --no-halt
```

You may also need to reconfigure Heroku to run the worker.
```sh
heroku ps:scale web=0 worker=1
```

Add your slack token and any other environment variables to Heroku
```sh
heroku config:set SLACK_API_TOKEN=xoxb-23486423876-HjgF354JHG7k567K4j56Gk3o
```

Push to Heroku
```sh
git add -A
git commit -m "initial commit"
git push heroku master
```

Your bot should be good to go. :metal:

## Creating a Route Handler Plugin

### First Steps

```sh
mix new alice_google_images
cd alice_google_images
rm lib/alice_google_images.ex test/alice_google_images_test.exs
mkdir -p lib/alice/handlers
mkdir -p test/alice/handlers
touch lib/alice/handlers/google_images.ex test/alice/handlers/google_images_test.exs
```

### Configuring the App

In `mix.exs`, update `application` and `deps` to look like the following:

```elixir
def application do
  [applications: []]
end

defp deps do
  [
    {:websocket_client, github: "jeremyong/websocket_client"},
    {:alice, "~> 0.4"}
  ]
end
```

### Using Alice.Console

If you want to use the built-in console to test your handler, first add the
handler in your `config/config.ex` (as well as any other configuration that your
handler might need):

```elixir
use Mix.Config

config :alice, handlers: [Alice.Handlers.GoogleImages]

config :alice_google_images,
  cse_id: System.get_env("GOOGLE_CSE_ID"),
  cse_token: System.get_env("GOOGLE_CSE_TOKEN"),
  safe_search_level: :medium
```

Then, start the console:

```sh
mix alice.console
Starting Alice Console

alice> img me pancakes
alice> https://example.com/pancake.png#123456789

alice> exit
alice> Goodbye!
```

### Writing Route Handlers

In `lib/alice/handlers/google_images.ex`:

```elixir
defmodule Alice.Handlers.GoogleImages do
  use Alice.Router

  command ~r/(image|img)\s+me (?<term>.+)/i, :fetch
  route   ~r/(image|img)\s+me (?<term>.+)/i, :fetch

  @doc "`img me alice in wonderland` - gets a random image from Google Images"
  def fetch(conn) do
    conn
    |> extract_term
    |> get_images
    |> select_image
    |> reply(conn)
  end

  #...
end
```
