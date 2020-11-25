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
      conn = start_connection("search")
      assert {:ok, ["user:1"]} = Search.query(conn, "test_collection", "default_bucket", "test")
      stop_connection(conn)
    end

    test "returns none element" do
      conn = start_connection("search")
      assert {:ok, []} = Search.query(conn, "test_collection", "default_bucket", "test")
      stop_connection(conn)
    end
  end
end
