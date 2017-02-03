defmodule Alice.Router.Helpers do
  @moduledoc """
  Helpers to make replying easier in handlers
  """

  alias Alice.Conn
  require Logger

  @doc """
  Reply to a message in a handler.

  Takes a conn and a response string in any order.
  Sends `response` back to the channel that triggered the handler.

  Adds random tag to end of image urls to break Slack's img cache.
  """
  @spec reply(String.t, %Conn{}) :: Conn.t
  @spec reply(%Conn{}, String.t) :: Conn.t
  @spec reply([String.t, ...], %Conn{}) :: Conn.t
  @spec reply(%Conn{}, [String.t, ...]) :: Conn.t
  def reply(resp, conn = %Conn{}), do: reply(conn, resp)
  def reply(conn = %Conn{}, resp) when is_list(resp), do: random_reply(conn, resp)
  def reply(conn = %Conn{message: %{channel: channel}, slack: slack}, resp) do
    resp
    |> Alice.Images.uncache
    |> adapter.send_message(channel, slack)
    conn
  end

  defp adapter do
    Alice.Adapters.selected_adapter
  end

  @doc """
  Takes a conn and a list of possible response in any order.
  Replies with a random element of the `list` provided.
  """
  @spec random_reply(list, Conn.t) :: Conn.t
  @spec random_reply(Conn.t, list) :: Conn.t
  def random_reply(list, conn = %Conn{}), do: random_reply(conn, list)
  def random_reply(conn = %Conn{}, list), do: list |> Enum.random |> reply(conn)

  @doc """
  Reply with random chance.

  Examples

      > chance_reply(conn, 0.5, "sent half the time")
      > chance_reply(conn, 0.25, "sent 25% of the time", "sent 75% of the time")
  """
  @spec chance_reply(Conn.t, float, String.t, String.t) :: Conn.t
  def chance_reply(conn = %Conn{}, chance, positive, negative \\ :noreply) do
    {:rand.uniform <= chance, negative}
    |> do_chance_reply(positive, conn)
  end

  defp do_chance_reply({true, _}, resp, conn = %Conn{}), do: reply(resp, conn)
  defp do_chance_reply({false, :noreply}, _, conn = %Conn{}), do: conn
  defp do_chance_reply({false, resp}, _, conn = %Conn{}), do: reply(resp, conn)

  @doc """
  Delay a reply. Alice will show to be typing while the message is delayed.

  The conn can be passed in first or last.

  Returns the task, not a conn. If you need to get the conn, you can
  use `Task.await(task)`, but this will block the handle process until the delay
  finishes. If you don't need the updated conn, simply return the conn that was
  passed to delayed_reply.

  Examples

      def hello(conn) do
        "hello" |> delayed_reply(1000, conn)
        conn
      end

      def hello(conn) do
        task = delayed_reply(conn, "hello", 1000)
        # other work...
        Task.await(task)
      end
  """
  @spec delayed_reply(Conn.t, String.t, integer) :: Task.t
  @spec delayed_reply(String.t, integer, Conn.t) :: Task.t
  def delayed_reply(msg, ms, conn = %Conn{}), do: delayed_reply(conn, msg, ms)
  def delayed_reply(conn = %Conn{}, message, milliseconds) do
    Task.async(fn ->
      conn = indicate_typing(conn)
      :timer.sleep(milliseconds)
      reply(message, conn)
    end)
  end

  @doc """
  Indicate typing.
  """
  @spec indicate_typing(Conn.t) :: Conn.t
  def indicate_typing(conn = %Conn{message: %{channel: chan}, slack: slack}) do
    adapter.indicate_typing(chan, slack)
    conn
  end


end
