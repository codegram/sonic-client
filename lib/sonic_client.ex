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
    {:ok, conn} = TcpConnection.start_link(host, port, [])
    {:ok, _msg} = TcpConnection.recv(conn)
    :ok = TcpConnection.send(conn, "START #{mode} #{password}")

    case TcpConnection.recv(conn) do
      {:ok, "STARTED " <> _msg} -> {:ok, conn}
    end
  end

  @doc """
  Stop connection with Sonic server
  """
  def stop(conn) do
    with(
      :ok <- TcpConnection.send(conn, "QUIT"),
      {:ok, _msg} <- TcpConnection.recv(conn)
    ) do
      TcpConnection.close(conn)
    end
  end

  @doc """
  Send PING message to Sonic server

      iex> {:ok, conn} = SonicClient.start(127.0.0.1, 1491, "search")
      iex> {:ok, conn} = SonicClient.ping(conn)
      PONG

  """
  def ping(conn) do
    TcpConnection.send(conn, "PING")
    TcpConnection.recv(conn)
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
