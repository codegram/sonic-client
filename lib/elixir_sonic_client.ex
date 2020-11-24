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
    {:ok, _msg} = TcpConnection.recv(conn)
    :ok = TcpConnection.send(conn, "START #{mode} #{password}")

    case TcpConnection.recv(conn) do
      {:ok, "STARTED " <> _msg} -> {:ok, conn}
    end
  end

  def ping(conn) do
    send_result = TcpConnection.send(conn, "PING")
    send_result |> inspect() |> IO.puts()
    recv_result = TcpConnection.recv(conn)
    recv_result |> inspect() |> IO.puts()
    recv_result
  end
end
