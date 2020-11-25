defmodule SonicClient.Modes.IngestTest do
  use ExUnit.Case
  alias SonicClient.Modes.Control
  alias SonicClient.Modes.Ingest

  @collection_0 "some_collection_name"
  @collection_1 "some_other_collection_name"
  @bucket_name_0 "some_bucket_name"
  @bucket_name_1 "some_other_bucket_name"
  @object_reference_0 "some_object"
  @object_reference_1 "some_other"
  @term "Some term to be searched."

  @tag :wip
  describe "#push" do
    test "push term to search for given connection, collection, bucket and object" do
      ingest_conn = connection("ingest")
      control_conn = connection("control")

      assert :ok ==
               Ingest.push(
                 ingest_conn,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 "Some term"
               )

      assert :ok == Control.consolidate(control_conn)
      assert 1 == Ingest.count(ingest_conn, @collection_0)
      assert :ok == Ingest.flush(ingest_conn, @collection_0)
      assert :ok == Control.consolidate(control_conn)
      assert 0 == Ingest.count(ingest_conn, @collection_0)

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

      assert :ok ==
               Ingest.push(
                 ingest_conn,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 "To be, or not to be, that is the question."
               )

      assert :ok ==
               Ingest.push(
                 ingest_conn,
                 @collection_0,
                 @bucket_name_1,
                 @object_reference_0,
                 "Whether it is nobler in the mind to suffer"
               )

      assert :ok ==
               Ingest.push(
                 ingest_conn,
                 @collection_1,
                 @bucket_name_0,
                 @object_reference_0,
                 "The slings and arrows of outrageous fortune,"
               )

      assert :ok == Control.consolidate(control_conn)
      assert 2 == Ingest.count(ingest_conn, @collection_0)
      assert 1 == Ingest.count(ingest_conn, @collection_1)
      assert :ok == Ingest.flush(ingest_conn, @collection_0)
      assert :ok == Ingest.flush(ingest_conn, @collection_1)
      assert :ok == Control.consolidate(control_conn)
      assert 0 == Ingest.count(ingest_conn, @collection_0)
      assert 0 == Ingest.count(ingest_conn, @collection_1)

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
