defmodule SonicClient.Modes.Search do
  @moduledoc """
  Module to search data on sonic.
  """
  alias SonicClient
  alias SonicClient.TcpConnection

  @default_limit 15

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
    command =
      ~s(QUERY #{collection} #{bucket} "#{terms}" #{limit_from_opts(opts)} #{
        offset_from_opts(opts)
      })

    TcpConnection.search_request(conn, command)
  end

  def suggest(conn, collection, bucket, terms, opts \\ [limit: 10]) do
    command = ~s(SUGGEST #{collection} #{bucket} "#{terms}" #{limit_from_opts(opts)})

    TcpConnection.search_request(conn, command)
  end

  defp limit_from_opts(opts) do
    if opts[:limit], do: "LIMIT(#{opts[:limit]})", else: "LIMIT(#{@default_limit})"
  end

  defp offset_from_opts(opts) do
    if opts[:offset], do: "OFFSET(#{opts[:offset]})", else: "OFFSET(0)"
  end
end
