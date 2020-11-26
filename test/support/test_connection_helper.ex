defmodule SonicClient.TestConnectionHelper do
  alias SonicClient
  @test_collection "test_collection"

  def start_connection(mode) do
    {:ok, conn} =
      SonicClient.start(
        host(),
        1491,
        mode,
        "SecretPassword"
      )

    conn
  end

  def add_data(object, term, collection \\ @test_collection) do
    ingest_conn = start_connection("ingest")
    SonicClient.push(ingest_conn, collection, object, term)
    stop_connection(ingest_conn)

    control_conn = start_connection("control")
    SonicClient.consolidate(control_conn)
    stop_connection(control_conn)
  end

  def flush(collection \\ @test_collection) do
    conn = start_connection("ingest")
    SonicClient.flush(conn, collection)
    stop_connection(conn)
  end

  def stop_connection(conn) do
    SonicClient.stop(conn)
  end

  defp host do
    Kernel.to_charlist(System.get_env("SONIC_HOST", "sonic"))
  end
end
