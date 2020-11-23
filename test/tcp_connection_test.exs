defmodule ElixirSonicClient.TcpConnectionTest do
  use ExUnit.Case
  alias ElixirSonicClient.TcpConnection

  describe "#start_link" do
    test "Successful connection" do
      assert {:ok, conn} = TcpConnection.start_link(Kernel.to_charlist("sonic"), 1491, [])
      assert {:ok, message} = TcpConnection.recv(conn)
      assert "CONNECTED" <> _ = List.to_string(message)
    end
  end

  describe "#send" do
    test "send start search message" do
      {:ok, conn} = TcpConnection.start_link(Kernel.to_charlist("sonic"), 1491, [])
      assert :ok = TcpConnection.send(conn, "START search SecretPassword")
    end
  end
end
