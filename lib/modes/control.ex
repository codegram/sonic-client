defmodule SonicClient.Modes.Control do
  alias SonicClient.TcpConnection

  def consolidate(conn) do
    command = "TRIGGER consolidate"

    case TcpConnection.request(conn, command) do
      {:ok, "OK"} -> :ok
      error -> error
    end
  end
end
