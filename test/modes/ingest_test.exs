defmodule SonicClient.Modes.IngestTest do
  use ExUnit.Case
  alias SonicClient.Modes.Control
  alias SonicClient.Modes.Ingest

  @collection "some_collection_name"
  @bucket_name "some_bucket_name"
  @object "some_object"
  @term "Some term to be searched."

  @tag :wip
  describe "#push" do
    test "push term to search for given connection, collection, bucket and object" do
      ingest_conn = connection("ingest")
      control_conn = connection("control")

      assert :ok == Ingest.push(ingest_conn, @collection, @bucket_name, @object, @term)
      assert :ok == Control.consolidate(control_conn)
      assert 1 == Ingest.count(ingest_conn, @collection)
      assert :ok == Ingest.flush(ingest_conn, @collection)
      assert :ok == Control.consolidate(control_conn)
      assert 0 == Ingest.count(ingest_conn, @collection)

      SonicClient.stop(ingest_conn)
      SonicClient.stop(control_conn)
    end
  end

  describe "#pop" do
  end

  @tag :wip
  describe "#count" do
    test "counts entries for a specific collection" do
      ingest_conn = connection("ingest")
      control_conn = connection("control")

      assert :ok == Ingest.push(ingest_conn, @collection, @bucket_name, @object, "Term 1")
      assert :ok == Ingest.push(ingest_conn, @collection, @bucket_name, @object, "Term 2")

      assert :ok ==
               Ingest.push(ingest_conn, "some_other_collection", @bucket_name, @object, "Term 3")

      assert :ok == Control.consolidate(control_conn)
      assert 2 == Ingest.count(ingest_conn, @collection)
      assert 1 == Ingest.count(ingest_conn, "some_other_collection")
      assert :ok == Ingest.flush(ingest_conn, @collection)
      assert :ok == Ingest.flush(ingest_conn, "some_other_collection")
      assert :ok == Control.consolidate(control_conn)
      assert 0 == Ingest.count(ingest_conn, @collection)
      assert 0 == Ingest.count(ingest_conn, "some_other_collection")

      SonicClient.stop(ingest_conn)
      SonicClient.stop(control_conn)
    end
  end

  describe "#flush" do
  end

  defp connection(mode) do
    with({:ok, conn} <- SonicClient.start(host(), 1491, mode, "SecretPassword")) do
      conn
    end
  end

  defp host do
    Kernel.to_charlist(System.get_env("SONIC_HOST", "sonic"))
  end
end
