defmodule ElixirSonicClient.Modes.Ingest do
  alias ElixirSonicClient.TcpConnection

  @default_bucket_name "default:bucket"

  def push(conn, collection, object, term) do
    TcpConnection.send(
      conn,
      "PUSH #{collection} #{@default_bucket_name} #{object} \"#{term}\""
    )

    response = TcpConnection.recv(conn)

    case response do
      {:ok, "OK"} -> :ok
      {:error, msg} -> {:error, msg}
    end
  end

  @spec count(any, any) :: nil
  def count(conn, collection) do
  end

  def flush(conn, collection) do
  end
end
