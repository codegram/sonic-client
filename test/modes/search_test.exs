defmodule SonicClient.Modes.SearchTest do
  use ExUnit.Case
  alias SonicClient.Modes.Search
  import SonicClient.TestConnectionHelper

  setup do
    flush()
    consolidate()

    add_data("user:1", "It is a common test that I love")
    add_data("user:2", "It is a common testable text that I love")
    add_data("user:3", "This color should not appear in the common search")
    consolidate()

    on_exit(fn -> flush() end)
  end

  describe "#query" do
    test "returns empty list" do
      conn = start_connection("search")

      assert {:ok, []} =
               Search.query(conn, "test_collection", "default_bucket", "non-existent",
                 locale: "eng"
               )

      stop_connection(conn)
    end

    @tag :wip
    test "returns list of elements" do
      conn = start_connection("search")

      assert {:ok, ["user:2", "user:1"]} =
               Search.query(conn, "test_collection", "default_bucket", "love", locale: "eng")

      stop_connection(conn)
    end

    test "returns list of elements based on alternate words" do
      conn = start_connection("search")

      assert {:ok, ["user:2", "user:1"]} =
               Search.query(conn, "test_collection", "default_bucket", "lovi", locale: "eng")

      stop_connection(conn)
    end

    test "returns list of elements when limit 1" do
      conn = start_connection("search")

      assert {:ok, ["user:3"]} =
               Search.query(conn, "test_collection", "default_bucket", "common",
                 limit: 1,
                 locale: "eng"
               )

      stop_connection(conn)
    end

    test "returns list of elements when offset 1" do
      conn = start_connection("search")

      assert {:ok, ["user:1"]} =
               Search.query(conn, "test_collection", "default_bucket", "love",
                 offset: 1,
                 locale: "eng"
               )

      stop_connection(conn)
    end

    test "returns list of elements when limit 1 and offset 1" do
      conn = start_connection("search")

      assert {:ok, ["user:2"]} =
               Search.query(conn, "test_collection", "default_bucket", "common",
                 limit: 1,
                 offset: 1,
                 locale: "eng"
               )

      stop_connection(conn)
    end
  end

  describe "#suggest" do
    test "returns list of suggestions" do
      conn = start_connection("search")

      assert {:ok, ["color", "common"]} =
               Search.suggest(conn, "test_collection", "default_bucket", "co")

      stop_connection(conn)
    end

    test "returns list of suggestions when limit 1" do
      conn = start_connection("search")

      assert {:ok, ["color"]} =
               Search.suggest(conn, "test_collection", "default_bucket", "co", limit: 1)

      stop_connection(conn)
    end
  end
end
