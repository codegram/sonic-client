defmodule SonicClient do
  alias SonicClient.Modes.Control
  alias SonicClient.Modes.Ingest
  alias SonicClient.TcpConnection

  @moduledoc """
  Client for [Sonic search backend](https://github.com/valeriansaliou/sonic)
  """

  @doc """
  Start Connection with Sonic Server.

  ## Examples

      iex> SonicClient.start(127.0.0.1, 1491, "search", "secret")
      {:ok, conn}

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

      iex> {:ok, conn} = SonicClient.start(127.0.0.1, 1491, "search")
      iex> {:ok, conn} = SonicClient.ping(conn)
      PONG

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
