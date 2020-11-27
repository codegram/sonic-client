defmodule SonicClient.Modes.Ingest do
  alias SonicClient.TcpConnection

  def push(conn, collection, bucket, object, term, locale) do
    command = ~s[PUSH #{collection} #{bucket} #{object} "#{term}" LANG(#{locale})]

    case TcpConnection.request(conn, command) do
      {:ok, "OK"} -> :ok
      error -> error
    end
  end

  def flush(conn, collection) do
    command = ~s[FLUSHC #{collection}]

    case TcpConnection.request(conn, command) do
      {:ok, "RESULT " <> _msg} ->
        :ok

      error ->
        error
    end
  end

  def flush(conn, collection, bucket) do
    command = ~s[FLUSHB #{collection} #{bucket}]

    case TcpConnection.request(conn, command) do
      {:ok, "RESULT " <> _msg} ->
        :ok

      error ->
        error
    end
  end

  def flush(conn, collection, bucket, object) do
    command = ~s[FLUSHO #{collection} #{bucket} #{object}]

    case TcpConnection.request(conn, command) do
      {:ok, "RESULT " <> _msg} ->
        :ok

      error ->
        error
    end
  end
end
