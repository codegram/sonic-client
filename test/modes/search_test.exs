defmodule SonicClient.Modes.SearchTest do
  use ExUnit.Case
  alias SonicClient.Modes.Search
  import SonicClient.TestConnectionHelper

  describe "#query" do
    setup do
      flush()
    end

    test "returns one element" do
      add_data("user:1", "this is a test")
      add_data("user:2", "It should not appear in the search")
      conn = start_connection("search")
      assert {:ok, ["user:1"]} = Search.query(conn, "test_collection", "default_bucket", "test")
      stop_connection(conn)
    end

    test "returns empty list" do
      conn = start_connection("search")
      assert {:ok, []} = Search.query(conn, "test_collection", "default_bucket", "test")
      stop_connection(conn)
    end

    test "returns list of elements" do
      add_data("user:1", "this is a test")
      add_data("user:2", "this is a testable text")

      conn = start_connection("search")

      assert {:ok, ["user:1", "user:2"]} =
               Search.query(conn, "test_collection", "default_bucket", "test")

      stop_connection(conn)
    end

    test "returns list of elements based on alternate words" do
      add_data("user:1", "this is a test")
      add_data("user:2", "this is a testable text")

      conn = start_connection("search")

      assert {:ok, ["user:1"]} = Search.query(conn, "test_collection", "default_bucket", "tist")

      stop_connection(conn)
    end
  end
end
