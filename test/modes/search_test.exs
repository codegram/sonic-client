defmodule SonicClient.Modes.SearchTest do
  use ExUnit.Case
  alias SonicClient.Modes.Search
  import SonicClient.TestConnectionHelper

  describe "#query" do
    test "returns elements" do
      add_data("user:1", "this is a test")

      conn = start_connection("search")
      assert {:error, :ok} = Search.query(conn, "test_collection", "default_bucket", "test")
      stop_connection(conn)

      flush()
    end
  end
end
