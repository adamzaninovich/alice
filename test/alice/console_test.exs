defmodule Alice.ConsoleTest do
  use ExUnit.Case, async: false

  alias Alice.Console
  import ExUnit.CaptureIO

  setup_all do
    start_supervised({Alice.Router, [Alice.Earmuffs, Alice.Handlers.Utils, Alice.Handlers.Help]})

    on_exit(fn ->
      Application.put_env(:alice, :outbound_client, Alice.ChatBackends.OutboundSpy)
    end)
  end

  test "exiting gracefully" do
    capture = capture_io("exit", fn -> Console.start() end)

    assert capture == "Starting Alice Console\nalice> Goodbye!\n"
  end

  test "sending routes to a handler" do
    capture = capture_io("ping\nexit", fn -> Console.start() end)

    possible_responses = [
      "Starting Alice Console\nalice> PONG!\nalice> Goodbye!\n",
      "Starting Alice Console\nalice> Can I help you?\nalice> Goodbye!\n",
      "Starting Alice Console\nalice> Yes...I'm still here.\nalice> Goodbye!\n",
      "Starting Alice Console\nalice> I'm alive!\nalice> Goodbye!\n"
    ]

    assert capture in possible_responses
  end

  test "sending commands to a handler" do
    capture = capture_io("@alice help\nexit", fn -> Console.start() end)

    assert capture == """
           Starting Alice Console
           alice> _Here are all the handlers I know about…_

           > *Earmuffs*
           > *Help*
           > *Utils*

           _Get info about a specific handler with_ `@alice help <handler name>`

           _Get info about all handlers with_ `@alice help all`

           _Feedback on Alice is appreciated. Please submit an issue at https://github.com/alice-bot/alice/issues _

           alice> Goodbye!
           """
  end

  test "earmuffs works in the console (and state is persisted between messages)" do
    capture = capture_io("@alice earmuffs\nping\nexit", fn -> Console.start() end)

    user = System.get_env("USER") || "console_user"

    assert capture == """
           Starting Alice Console
           alice> <@#{user}> :mute:
           alice> alice> Goodbye!
           """
  end
end
