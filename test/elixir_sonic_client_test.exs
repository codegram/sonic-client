defmodule ElixirSonicClientTest do
  use ExUnit.Case

  test "start search mode" do
    assert {:ok, conn} =
             ElixirSonicClient.start(
               Kernel.to_charlist("sonic"),
               1491,
               "search",
               "SecretPassword"
             )

    # conn |> inspect |> IO.puts()
  end

  @tag :wip
  test "ping" do
    {:ok, conn} =
      ElixirSonicClient.start(
        Kernel.to_charlist("sonic"),
        1491,
        "search",
        "SecretPassword"
      )

    # conn |> inspect |> IO.puts()
    assert {:ok, Kernel.to_charlist("PONG\r\n")} == ElixirSonicClient.ping(conn)
  end
end
