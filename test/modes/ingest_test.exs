defmodule SonicClient.Modes.IngestTest do
  use ExUnit.Case
  alias SonicClient.Modes.Ingest
  alias SonicClient.Modes.Search
  import SonicClient.TestConnectionHelper

  @collection_0 "plays"
  @bucket_name_0 "reader_0"
  @bucket_name_1 "reader_1"
  @object_reference_0 "hamlet"
  @object_reference_1 "macbeth"
  @locale "eng"

  @line_0 "Whether it is nobler in the mind to suffer the slings and arrows of outrageous fortune,"
  @line_1 "When shall we three meet again, in thunder, lightning, or in rain?"

  describe "#push" do
    test "push term to search for given connection, collection, bucket, object and locale" do
      ingest_connection = start_connection("ingest")
      search_connection = start_connection("search")

      assert :ok ==
               Ingest.push(
                 ingest_connection,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 @line_0,
                 @locale
               )

      assert :ok ==
               Ingest.push(
                 ingest_connection,
                 @collection_0,
                 @bucket_name_1,
                 @object_reference_1,
                 @line_1,
                 @locale
               )

      consolidate()

      assert {:ok, [@object_reference_0]} =
               Search.query(
                 search_connection,
                 @collection_0,
                 @bucket_name_0,
                 "outrageous"
               )

      assert {:ok, [@object_reference_1]} =
               Search.query(
                 search_connection,
                 @collection_0,
                 @bucket_name_1,
                 "thunder"
               )

      assert :ok == Ingest.flush(ingest_connection, @collection_0)

      consolidate()

      stop_connection(search_connection)
      stop_connection(ingest_connection)
    end
  end

  describe "#flush" do
    test "flushes a whole collection" do
      ingest_connection = start_connection("ingest")
      search_connection = start_connection("search")

      assert :ok ==
               Ingest.push(
                 ingest_connection,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 @line_0,
                 @locale
               )

      assert :ok ==
               Ingest.push(
                 ingest_connection,
                 @collection_0,
                 @bucket_name_1,
                 @object_reference_1,
                 @line_1,
                 @locale
               )

      consolidate()

      assert :ok == Ingest.flush(ingest_connection, @collection_0)
      assert :ok == Ingest.flush(ingest_connection, @collection_0)

      consolidate()

      assert {:ok, []} =
               Search.query(
                 search_connection,
                 @collection_0,
                 @bucket_name_0,
                 "outrageous"
               )

      assert {:ok, []} =
               Search.query(
                 search_connection,
                 @collection_0,
                 @bucket_name_1,
                 "thunder"
               )

      stop_connection(search_connection)
      stop_connection(ingest_connection)
    end

    test "flushes a bucket" do
      ingest_connection = start_connection("ingest")
      search_connection = start_connection("search")

      assert :ok ==
               Ingest.push(
                 ingest_connection,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 @line_0,
                 @locale
               )

      assert :ok ==
               Ingest.push(
                 ingest_connection,
                 @collection_0,
                 @bucket_name_1,
                 @object_reference_1,
                 @line_1,
                 @locale
               )

      consolidate()

      assert :ok == Ingest.flush(ingest_connection, @collection_0, @bucket_name_0)

      consolidate()

      assert {:ok, []} =
               Search.query(
                 search_connection,
                 @collection_0,
                 @bucket_name_0,
                 "outrageous"
               )

      assert {:ok, [@object_reference_1]} =
               Search.query(
                 search_connection,
                 @collection_0,
                 @bucket_name_1,
                 "thunder"
               )

      stop_connection(search_connection)
      stop_connection(ingest_connection)
    end

    test "flushes an object" do
      ingest_connection = start_connection("ingest")
      search_connection = start_connection("search")

      assert :ok ==
               Ingest.push(
                 ingest_connection,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_0,
                 @line_0,
                 @locale
               )

      assert :ok ==
               Ingest.push(
                 ingest_connection,
                 @collection_0,
                 @bucket_name_0,
                 @object_reference_1,
                 @line_1,
                 @locale
               )

      consolidate()

      assert :ok ==
               Ingest.flush(ingest_connection, @collection_0, @bucket_name_0, @object_reference_0)

      consolidate()

      assert {:ok, []} =
               Search.query(
                 search_connection,
                 @collection_0,
                 @bucket_name_0,
                 "outrageous"
               )

      assert {:ok, [@object_reference_1]} =
               Search.query(
                 search_connection,
                 @collection_0,
                 @bucket_name_0,
                 "thunder"
               )

      stop_connection(search_connection)
      stop_connection(ingest_connection)
    end
  end
end
