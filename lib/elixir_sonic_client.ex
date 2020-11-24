defmodule ElixirSonicClient do
  alias ElixirSonicClient.TcpConnection

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

  ## Examples
      iex> {:ok, conn} = ElixirSonicClient.ping(conn)
      {:ok, "PONG"}
  """
  def ping(conn) do
    TcpConnection.send(conn, "PING")
    TcpConnection.recv(conn)
  end
end
