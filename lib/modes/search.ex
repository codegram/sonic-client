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
    limit = limit_from_opts(opts)
    offset = offset_from_opts(opts)
    locale = locale_from_opts(opts)

    command = ~s(QUERY #{collection} #{bucket} "#{terms}" #{limit} #{offset} #{locale})

    TcpConnection.search_request(conn, command)
  end

  @doc """
  Search for suggestion of words for autocomplete

  ## Examples

  iex> {:ok, conn} = SonicClient.start(127.0.0.1, 1491, "search", "secret")

  iex> SonicClient.Modes.Search.suggest("my_collection", "bucket", "te")
  {:ok, ["test", "testable"]}

  iex> SonicClient.Modes.Search.suggest("my_collection", "bucket", "te", limit: 1)
  {:ok, ["test"]}

  """
  def suggest(conn, collection, bucket, word, opts \\ [limit: 10]) do
    limit = limit_from_opts(opts)
    command = ~s(SUGGEST #{collection} #{bucket} "#{word}" #{limit})

    TcpConnection.search_request(conn, command)
  end

  defp limit_from_opts(opts) do
    if opts[:limit], do: "LIMIT(#{opts[:limit]})", else: "LIMIT(#{@default_limit})"
  end

  defp offset_from_opts(opts) do
    if opts[:offset], do: "OFFSET(#{opts[:offset]})", else: "OFFSET(0)"
  end

  defp locale_from_opts(opts) do
    if opts[:locale], do: "LANG(#{opts[:locale]})", else: ""
  end
end
