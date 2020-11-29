defmodule SonicClient.TestConnectionHelper do
  alias SonicClient
  alias SonicClient.Modes.Control
  alias SonicClient.Modes.Ingest

  @test_collection "test_collection"
  @test_bucket "default_bucket"
  @default_locale "eng"

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

  def add_data(
        object,
        term,
        collection \\ @test_collection,
        bucket \\ @test_bucket,
        locale \\ @default_locale
      ) do
    ingest_conn = start_connection("ingest")
    Ingest.push(ingest_conn, collection, bucket, object, term, locale)
    stop_connection(ingest_conn)

    consolidate()
  end

  def consolidate do
    conn = start_connection("control")
    Control.consolidate(conn)
    stop_connection(conn)
  end

  def flush(collection \\ @test_collection, bucket \\ @test_bucket) do
    conn = start_connection("ingest")
    Ingest.flush(conn, collection, bucket)
    stop_connection(conn)
  end

  def stop_connection(conn) do
    SonicClient.stop(conn)
  end

  def host do
    Kernel.to_charlist(System.get_env("SONIC_HOST", "sonic"))
  end
end
