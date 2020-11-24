defmodule ElixirSonicClient do
  alias ElixirSonicClient.TcpConnection
  alias ElixirSonicClient.Modes.Ingest
  alias ElixirSonicClient.Modes.Control

  @moduledoc """
  Client for [Sonic search backend](https://github.com/valeriansaliou/sonic)
  """

  @doc """
  Start Connection with Sonic Server.

  ## Examples
      iex> ElixirSonicClient.start(
        Kernel.to_charlist("sonic"),
        1491,
        "search",
        "SecretPassword"
      )
      {:ok, #PID<0.202.0>}
  """
  def start(host, port, mode, password) do
    command = "START #{mode} #{password}"

    with {:ok, conn} <- TcpConnection.open(host, port, []) do
      case TcpConnection.request(conn, command) do
        {:ok, "STARTED " <> _msg} -> {:ok, conn}
        error -> error
      end
    else
      error -> error
    end
  end

  @doc """
  Stop connection with Sonic server
  """
  def stop(conn) do
    command = "QUIT"

    with({:ok, _msg} <- TcpConnection.request(conn, command)) do
      TcpConnection.close(conn)
    else
      error -> error
    end
  end

  @doc """
  Send PING message to Sonic server

  ## Examples
      iex> {:ok, conn} = ElixirSonicClient.ping(conn)
      {:ok, "PONG"}
  """
  def ping(conn) do
    command = "PING"
    TcpConnection.request(conn, command)
  end

  def push(conn, collection, object, term) do
    Ingest.push(conn, collection, object, term)
  end

  def count(conn, collection) do
    Ingest.count(conn, collection)
  end

  def flush(conn, collection) do
    Ingest.flush(conn, collection)
  end

  def consolidate(conn) do
    Control.consolidate(conn)
  end
end
