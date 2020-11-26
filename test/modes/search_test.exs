defmodule SonicClient.Modes.SearchTest do
  use ExUnit.Case
  alias SonicClient.Modes.Search
  import SonicClient.TestConnectionHelper

  describe "#query" do
    setup do
      add_data("user:1", "It is a test")
      add_data("user:2", "It is a testable text")
      add_data("user:3", "It should not appear in the search")

      on_exit(fn -> flush() end)
    end

    test "returns empty list" do
      conn = start_connection("search")
      assert {:ok, []} = Search.query(conn, "test_collection", "default_bucket", "non-existent")
      stop_connection(conn)
    end

    test "returns list of elements" do
      conn = start_connection("search")

      assert {:ok, ["user:1", "user:2"]} =
               Search.query(conn, "test_collection", "default_bucket", "test")

      stop_connection(conn)
    end

    test "returns list of elements based on alternate words" do
      conn = start_connection("search")

      assert {:ok, ["user:1"]} = Search.query(conn, "test_collection", "default_bucket", "tist")

      stop_connection(conn)
    end

    test "returns list of elements with limit 1" do
      conn = start_connection("search")

      assert {:ok, ["user:1"]} =
               Search.query(conn, "test_collection", "default_bucket", "test", limit: 1)

      stop_connection(conn)
    end
  end
end
