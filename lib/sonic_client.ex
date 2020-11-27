defmodule SonicClient do
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

    case TcpConnection.open(host, port, mode: :binary, packet: :line) do
      {:ok, conn} ->
        case TcpConnection.request(conn, command) do
          {:ok, "STARTED " <> _msg} -> {:ok, conn}
          error -> error
        end

      error ->
        error
    end
  end

  @doc """
  Stop connection with Sonic server
  """
  def stop(conn) do
    command = "QUIT"

    case TcpConnection.request(conn, command) do
      {:ok, _msg} -> TcpConnection.close(conn)
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
end
