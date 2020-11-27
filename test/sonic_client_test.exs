defmodule SonicClientTest do
  use ExUnit.Case
  alias SonicClient.TcpConnection
  import SonicClient.TestConnectionHelper

  test "start search mode" do
    assert {:ok, conn} =
             SonicClient.start(
               host(),
               1491,
               "search",
               "SecretPassword"
             )

    TcpConnection.close(conn)
  end

  test "ping" do
    {:ok, conn} =
      SonicClient.start(
        host(),
        1491,
        "search",
        "SecretPassword"
      )

    assert {:ok, "PONG"} == SonicClient.ping(conn)
    TcpConnection.close(conn)
  end

  test "stop connection" do
    {:ok, conn} =
      SonicClient.start(
        host(),
        1491,
        "search",
        "SecretPassword"
      )

    assert :ok = SonicClient.stop(conn)
  end

  defp host do
    Kernel.to_charlist(System.get_env("SONIC_HOST", "sonic"))
  end
end
