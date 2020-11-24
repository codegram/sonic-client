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
      _ -> response
    end
  end

  def count(conn, collection) do
    TcpConnection.send(
      conn,
      "COUNT #{collection}"
    )

    response = TcpConnection.recv(conn)

    case response do
      {:ok, "RESULT " <> num_str} ->
        case Integer.parse(num_str) do
          {num, _} -> num
        end

      _ ->
        response
    end
  end

  def flush(conn, collection) do
  end
end
