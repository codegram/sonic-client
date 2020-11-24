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

  test "stop connection" do
    {:ok, conn} =
      ElixirSonicClient.start(
        Kernel.to_charlist("sonic"),
        1491,
        "search",
        "SecretPassword"
      )

    ElixirSonicClient.stop(conn)
  end

  @tag :wip
  test "add data to the index" do
    {:ok, conn} =
      ElixirSonicClient.start(
        Kernel.to_charlist("sonic"),
        1491,
        "ingest",
        "SecretPassword"
      )

    collection = "some_collection"
    object = "some_object"
    term = "The term."

    assert :ok == ElixirSonicClient.push(conn, collection, object, term)
    IO.inspect(ElixirSonicClient.count(conn, collection))
    assert 1 == ElixirSonicClient.count(conn, collection)
    assert :ok == ElixirSonicClient.flush(conn, collection)
    assert 0 == ElixirSonicClient.count(conn, collection)

    ElixirSonicClient.stop(conn)
  end
end
