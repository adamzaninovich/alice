defmodule Mix.Tasks.Alice.ConsoleTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup_all do
    start_supervised({Alice.Router, [Alice.Handlers.Utils, Alice.Handlers.Help]})

    on_exit(fn ->
      Application.put_env(:alice, :outbound_client, Alice.ChatBackends.OutboundSpy)
    end)
  end

  test "it should startup the console" do
    capture =
      capture_io("exit", fn ->
        Mix.Tasks.Alice.Console.run(nil)
      end)

    assert capture == "Starting Alice Console\nalice> Goodbye!\n"
  end
end
