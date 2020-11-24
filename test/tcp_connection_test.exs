defmodule ElixirSonicClient.TcpConnectionTest do
  use ExUnit.Case
  alias ElixirSonicClient.TcpConnection

  describe "#start_link" do
    test "Successful connection" do
      assert {:ok, conn} = TcpConnection.start_link(host(), 1491, [])
      assert {:ok, message} = TcpConnection.recv(conn)
      assert "CONNECTED" <> _ = message
      TcpConnection.close(conn)
    end
  end

  describe "#send" do
    test "send start search message" do
      {:ok, conn} = TcpConnection.start_link(host(), 1491, [])
      assert :ok = TcpConnection.send(conn, "START search SecretPassword")
      TcpConnection.close(conn)
    end

    test "send invalid mode" do
      {:ok, conn} = TcpConnection.start_link(host(), 1491, [])
      TcpConnection.recv(conn)
      assert :ok = TcpConnection.send(conn, "START invalid SecretPassword")
      assert {:ok, "ENDED invalid_mode"} = TcpConnection.recv(conn)
      TcpConnection.close(conn)
    end

    test "send invalid command" do
      conn = connection()
      assert :ok = TcpConnection.send(conn, "invalid command")
      assert {:error, _} = TcpConnection.recv(conn)
      TcpConnection.close(conn)
    end
  end

  defp connection(mode \\ "search") do
    {:ok, conn} = TcpConnection.start_link(host(), 1491, [])
    {:ok, _msg} = TcpConnection.recv(conn)
    :ok = TcpConnection.send(conn, "START #{mode} SecretPassword")
    {:ok, _msg} = TcpConnection.recv(conn)

    conn
  end

  defp host do
    Kernel.to_charlist(System.get_env("SONIC_HOST", "sonic"))
  end
end
