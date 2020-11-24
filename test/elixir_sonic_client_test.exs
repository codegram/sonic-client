defmodule ElixirSonicClientTest do
  use ExUnit.Case
  alias ElixirSonicClient.TcpConnection

  test "start search mode" do
    assert {:ok, conn} =
             ElixirSonicClient.start(
               host(),
               1491,
               "search",
               "SecretPassword"
             )

    TcpConnection.close(conn)
  end

  test "ping" do
    {:ok, conn} =
      ElixirSonicClient.start(
        host(),
        1491,
        "search",
        "SecretPassword"
      )

    assert {:ok, "PONG"} == ElixirSonicClient.ping(conn)
    TcpConnection.close(conn)
  end

  defp host do
    Kernel.to_charlist(System.get_env("SONIC_HOST", "sonic"))
  end
end
