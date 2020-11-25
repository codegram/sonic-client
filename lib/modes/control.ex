defmodule SonicClient.Modes.Control do
  alias SonicClient.TcpConnection

  def consolidate(conn) do
    TcpConnection.send(
      conn,
      "TRIGGER consolidate"
    )

    response = TcpConnection.recv(conn)

    case response do
      {:ok, "OK"} -> :ok
      _ -> response
    end
  end
end
