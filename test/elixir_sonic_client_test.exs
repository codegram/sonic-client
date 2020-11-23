defmodule ElixirSonicClientTest do
  use ExUnit.Case
  doctest ElixirSonicClient

  alias ElixirSonicClient.Pinger

  test "greets the world" do
    assert ElixirSonicClient.hello() == :world
  end

  test "pings Sonic" do
    result = Pinger.ping()

    result
    |> inspect
    |> IO.puts()

    # IO.puts(inspect(result))
  end
end
