defmodule ElixirSonicClientTest do
  use ExUnit.Case
  doctest ElixirSonicClient

  test "greets the world" do
    assert ElixirSonicClient.hello() == :world
  end
end
