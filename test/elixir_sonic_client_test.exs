defmodule SonicClientTest do
  use ExUnit.Case
  alias SonicClient.TcpConnection

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
      ElixirSonicClient.start(
        Kernel.to_charlist("sonic"),
        1491,
        "search",
        "SecretPassword"
      )

    ElixirSonicClient.stop(conn)
  end

  test "add data to the index" do
    collection = "some_collection"
    object = "some_object"
    term = "The term."

    {:ok, conn} =
      ElixirSonicClient.start(
        host(),
        1491,
        "ingest",
        "SecretPassword"
      )

    assert :ok == ElixirSonicClient.push(conn, collection, object, term)
    ElixirSonicClient.stop(conn)

    {:ok, conn} =
      ElixirSonicClient.start(
        host(),
        1491,
        "control",
        "SecretPassword"
      )

    assert :ok == ElixirSonicClient.consolidate(conn)
    ElixirSonicClient.stop(conn)

    {:ok, conn} =
      ElixirSonicClient.start(
        host(),
        1491,
        "ingest",
        "SecretPassword"
      )

    assert 1 == ElixirSonicClient.count(conn, collection)
    assert :ok == ElixirSonicClient.flush(conn, collection)
    ElixirSonicClient.stop(conn)

    {:ok, conn} =
      ElixirSonicClient.start(
        host(),
        1491,
        "control",
        "SecretPassword"
      )

    assert :ok == ElixirSonicClient.consolidate(conn)
    ElixirSonicClient.stop(conn)

    {:ok, conn} =
      ElixirSonicClient.start(
        host(),
        1491,
        "ingest",
        "SecretPassword"
      )

    assert 0 == ElixirSonicClient.count(conn, collection)
    ElixirSonicClient.stop(conn)
  end

  defp host do
    Kernel.to_charlist(System.get_env("SONIC_HOST", "sonic"))
  end
end
