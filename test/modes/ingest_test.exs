defmodule SonicClient.Modes.IngestTest do
  use ExUnit.Case
  alias SonicClient.Modes.Control
  alias SonicClient.Modes.Ingest
  import SonicClient.TestConnectionHelper

  @collection_0 "some_collection_name"
  @collection_1 "some_other_collection_name"
  @bucket_name_0 "some_bucket_name"
  @bucket_name_1 "some_other_bucket_name"
  @object_reference_0 "some_object"
  @object_reference_1 "some_other"
  @term "Some term to be searched."

  describe "#push" do
    @tag :wip
    test "push term to search for given connection, collection, bucket, object and locale" do
      conn = start_connection("ingest")

      assert :ok ==
               Ingest.push(
                 conn,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 "nectar",
                 "eng"
               )

      consolidate()

      assert 1 == Ingest.count(conn, @collection_0)
      assert :ok == Ingest.flush(conn, @collection_0)

      consolidate()

      assert 0 == Ingest.count(conn, @collection_0)

      stop_connection(conn)
    end
  end

  describe "#pop" do
  end

  describe "#count" do
    test "counts buckets for a specific collection" do
      conn = start_connection("ingest")

      assert :ok ==
               Ingest.push(
                 conn,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 "To be, or not to be, that is the question:"
               )

      assert :ok ==
               Ingest.push(
                 conn,
                 @collection_0,
                 @bucket_name_1,
                 @object_reference_0,
                 "Whether it is nobler in the mind to suffer"
               )

      assert :ok ==
               Ingest.push(
                 conn,
                 @collection_1,
                 @bucket_name_0,
                 @object_reference_0,
                 "The slings and arrows of outrageous fortune,"
               )

      consolidate()

      assert 2 == Ingest.count(conn, @collection_0)
      assert 1 == Ingest.count(conn, @collection_1)
      assert :ok == Ingest.flush(conn, @collection_0)
      assert :ok == Ingest.flush(conn, @collection_1)

      consolidate()

      assert 0 == Ingest.count(conn, @collection_0)
      assert 0 == Ingest.count(conn, @collection_1)

      stop_connection(conn)
    end

    # @tag :wip
    test "counts objects for a specific bucket in a collection" do
      conn = start_connection("ingest")

      assert :ok == Ingest.flush(conn, @collection_0, @bucket_name_0)
      assert :ok == Ingest.flush(conn, @collection_0, @bucket_name_1)

      consolidate()

      assert :ok ==
               Ingest.push(
                 conn,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 "question",
                 "eng"
               )

      assert :ok ==
               Ingest.push(
                 conn,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 "question",
                 "eng"
               )

      # assert :ok ==
      #          Ingest.push(
      #            conn,
      #            @collection_0,
      #            @bucket_name_1,
      #            @object_reference_0,
      #            "The slings and arrows of outrageous fortune,"
      #          )

      # assert :ok == Ingest.flush(conn, @collection_0, @bucket_name_0)
      # assert :ok == Ingest.flush(conn, @collection_0, @bucket_name_1)
      # assert :ok == Ingest.flush(conn, @collection_0)

      consolidate()

      assert 1 == Ingest.count(conn, @collection_0, @bucket_name_0)
      # assert 1 == Ingest.count(conn, @collection_0, @bucket_name_1, @object_reference_0)
      assert :ok == Ingest.flush(conn, @collection_0, @bucket_name_0)
      assert :ok == Ingest.flush(conn, @collection_0, @bucket_name_1)
      # assert :ok == Ingest.flush(conn, @collection_0)

      consolidate()

      assert 0 == Ingest.count(conn, @collection_0, @bucket_name_0, @object_reference_0)
      assert 0 == Ingest.count(conn, @collection_0, @bucket_name_1, @object_reference_0)

      stop_connection(conn)
    end
  end

  describe "#flush" do
  end
end
