defmodule SonicClient.Modes.Search do
  @moduledoc """
  Module to search data on sonic.
  """
  alias SonicClient
  alias SonicClient.TcpConnection

  @doc """
  Query sonic database

  ## Examples

  iex> {:ok, conn} = SonicClient.start(127.0.0.1, 1491, "search", "secret")

  iex> SonicClient.Modes.Search.query("my_collection", "bucket", "test")
  {:ok, ["object1", "object2"]}

  iex> SonicClient.Modes.Search.query("my_collection", "bucket", "test", limit: 1)
  {:ok, ["object1"]}

  iex> SonicClient.Modes.Search.query("my_collection", "bucket", "test", limit: 1, offset: 1)
  {:ok, ["object2"]}

  """
  def query(conn, collection, bucket, terms, opts \\ [limit: 10, offset: 0]) do
    limit_param = if opts[:limit], do: "LIMIT(#{opts[:limit]})", else: "LIMIT(10)"
    offset_param = if opts[:offset], do: "OFFSET(#{opts[:offset]})", else: "OFFSET(0)"

    command = ~s(QUERY #{collection} #{bucket} "#{terms}" #{limit_param} #{offset_param})
    TcpConnection.search_request(conn, command)
  end
end
