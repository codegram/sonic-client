defmodule SonicClient.Modes.Control do
  alias SonicClient.TcpConnection

  @spec consolidate(pid) :: :ok | {:error, any} | {:ok, binary}
  def consolidate(conn) do
    command = "TRIGGER consolidate"

    case TcpConnection.request(conn, command) do
      {:ok, "OK"} -> :ok
      error -> error
    end
  end
end
