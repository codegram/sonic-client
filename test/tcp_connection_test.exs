defmodule SonicClient.TcpConnectionTest do
  use ExUnit.Case
  alias SonicClient.TcpConnection

  describe "#open" do
    test "Successful connection" do
      {:ok, conn} = TcpConnection.open(host(), 1491)
      TcpConnection.close(conn)
    end
  end

  describe "#request" do
    test "send start search message" do
      {:ok, conn} = TcpConnection.open(host(), 1491)

      assert {:ok, "STARTED search protocol(1) buffer(20000)"} =
               TcpConnection.request(conn, "START search SecretPassword")

      TcpConnection.close(conn)
    end

    test "send invalid mode" do
      {:ok, conn} = TcpConnection.open(host(), 1491)

      assert {:ok, "ENDED invalid_mode"} =
               TcpConnection.request(conn, "START invalid SecretPassword")

      TcpConnection.close(conn)
    end

    test "send invalid command" do
      conn = connection()
      assert {:error, _} = TcpConnection.request(conn, "invalid command")
      TcpConnection.close(conn)
    end
  end

  defp connection(mode \\ "search") do
    with(
      {:ok, conn} <- TcpConnection.open(host(), 1491),
      {:ok, _msg} <- TcpConnection.request(conn, "START #{mode} SecretPassword")
    ) do
      conn
    end
  end

  defp host do
    Kernel.to_charlist(System.get_env("SONIC_HOST", "sonic"))
  end
end
