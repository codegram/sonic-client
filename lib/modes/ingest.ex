defmodule SonicClient.Modes.Ingest do
  alias SonicClient.TcpConnection

  @spec push(pid, String.t(), String.t(), String.t(), String.t(), String.t()) ::
          :ok | {:error, any} | {:ok, binary}
  def push(conn, collection, bucket, object, term, locale) do
    command = ~s[PUSH #{collection} #{bucket} #{object} "#{term}" LANG(#{locale})]

    case TcpConnection.request(conn, command) do
      {:ok, "OK"} -> :ok
      error -> error
    end
  end

  @spec flush(pid(), String.t()) :: :ok | {:error, any} | {:ok, binary}
  def flush(conn, collection) do
    ~s[FLUSHC #{collection}]
    |> (&send_flush_request(conn, &1)).()
  end

  @spec flush(pid(), String.t(), String.t()) :: :ok | {:error, any} | {:ok, binary}
  def flush(conn, collection, bucket) do
    ~s[FLUSHB #{collection} #{bucket}]
    |> (&send_flush_request(conn, &1)).()
  end

  @spec flush(pid(), String.t(), String.t(), String.t()) :: :ok | {:error, any} | {:ok, binary}
  def flush(conn, collection, bucket, object) do
    ~s[FLUSHO #{collection} #{bucket} #{object}]
    |> (&send_flush_request(conn, &1)).()
  end

  defp send_flush_request(conn, command) do
    case TcpConnection.request(conn, command) do
      {:ok, "RESULT " <> _msg} ->
        :ok

      error ->
        error
    end
  end
end
