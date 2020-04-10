defmodule Alice.Handlers.UtilsTest do
  use ExUnit.Case
  use Alice.Handlers.Case, handlers: Alice.Handlers.Utils

  test "it should respond to a ping" do
    receive_message("ping")

    assert Enum.member?(["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"], first_reply())
  end

  test "it should respond with info about the running bot" do
    receive_message("<@alice> info")

    {:ok, version} = :application.get_key(:alice, :vsn)
    assert first_reply() == "Alice #{version} - https://github.com/alice-bot"
  end
end