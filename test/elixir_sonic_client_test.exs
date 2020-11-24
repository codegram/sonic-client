defmodule ElixirSonicClientTest do
  use ExUnit.Case
  alias ElixirSonicClient.TcpConnection

  test "start search mode" do
    assert {:ok, conn} =
             ElixirSonicClient.start(
               Kernel.to_charlist("sonic"),
               1491,
               "search",
               "SecretPassword"
             )

    TcpConnection.close(conn)
  end

  test "ping" do
    {:ok, conn} =
      ElixirSonicClient.start(
        Kernel.to_charlist("sonic"),
        1491,
        "search",
        "SecretPassword"
      )

    assert {:ok, "PONG"} == ElixirSonicClient.ping(conn)
    TcpConnection.close(conn)
  end

  @tag :wip
  test "stop" do
    {:ok, conn} =
      ElixirSonicClient.start(
        Kernel.to_charlist("sonic"),
        1491,
        "search",
        "SecretPassword"
      )

    inspect(ElixirSonicClient.stop(conn))
  end
end
