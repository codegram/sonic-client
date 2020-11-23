defmodule ElixirSonicClientTest do
  use ExUnit.Case

  test "start search mode" do
    assert {:ok, _conn} =
             ElixirSonicClient.start(
               Kernel.to_charlist("sonic"),
               1491,
               "search",
               "SecretPassword"
             )
  end

  test "ping" do
    {:ok, conn} =
      ElixirSonicClient.start(
        Kernel.to_charlist("sonic"),
        1491,
        "search",
        "SecretPassword"
      )

    assert {:ok, Kernel.to_charlist("PONG\r\n")} == ElixirSonicClient.ping(conn)
  end

  test "pings Sonic" do
    result = Pinger.ping()

    result
    |> inspect
    |> IO.puts()

    # IO.puts(inspect(result))
  end
end
