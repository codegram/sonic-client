defmodule ElixirSonicClient do
  alias ElixirSonicClient.TcpConnection

  @moduledoc """
  Client for [Sonic search backend](https://github.com/valeriansaliou/sonic)
  """

  @doc """
  Start Connection with Sonic Server.

  ## Examples

      iex> ElixirSonicClient.start(127.0.0.1, 1491, "search")
      :world

  """
  def start(host, port, mode, password) do
    {:ok, conn} = TcpConnection.start_link(host, port, [])
    TcpConnection.send(conn, "START #{mode} #{password}")
    TcpConnection.recv(conn)
    {:ok, conn}
  end

  def ping(conn) do
    TcpConnection.send(conn, "PING")
    TcpConnection.recv(conn)
  end
end
