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
      SonicClient.start(
        Kernel.to_charlist("sonic"),
        1491,
        "search",
        "SecretPassword"
      )

    SonicClient.stop(conn)
  end

  test "add data to the index" do
    collection = "some_collection"
    object = "some_object"
    term = "The term."

    {:ok, conn} =
      SonicClient.start(
        host(),
        1491,
        "ingest",
        "SecretPassword"
      )

    assert :ok == SonicClient.push(conn, collection, object, term)
    SonicClient.stop(conn)

    {:ok, conn} =
      SonicClient.start(
        host(),
        1491,
        "control",
        "SecretPassword"
      )

    assert :ok == SonicClient.consolidate(conn)
    SonicClient.stop(conn)

    {:ok, conn} =
      SonicClient.start(
        host(),
        1491,
        "ingest",
        "SecretPassword"
      )

    assert 1 == SonicClient.count(conn, collection)
    assert :ok == SonicClient.flush(conn, collection)
    SonicClient.stop(conn)

    {:ok, conn} =
      SonicClient.start(
        host(),
        1491,
        "control",
        "SecretPassword"
      )

    assert :ok == SonicClient.consolidate(conn)
    SonicClient.stop(conn)

    {:ok, conn} =
      SonicClient.start(
        host(),
        1491,
        "ingest",
        "SecretPassword"
      )

    assert 0 == SonicClient.count(conn, collection)
    SonicClient.stop(conn)
  end

  defp host do
    Kernel.to_charlist(System.get_env("SONIC_HOST", "sonic"))
  end
end
