defmodule SonicClient.Modes.Ingest do
  alias SonicClient.TcpConnection

  @spec push(pid, String.t(), String.t(), String.t(), String.t(), String.t()) ::
          :ok | {:error, any} | {:ok, binary}
  @doc """
  Add a term for a given locale related to an object in the context a collection's bucket.

  Sends Sonic command: `PUSH <collection> <bucket> <object> "<term>" LANG(<locale>)`
  """
  def push(conn, collection, bucket, object, term, locale) do
    command = ~s[PUSH #{collection} #{bucket} #{object} "#{term}" LANG(#{locale})]

    case TcpConnection.request(conn, command) do
      {:ok, "OK"} -> :ok
      error -> error
    end
  end

  @spec flush(pid(), String.t()) :: :ok | {:error, any} | {:ok, binary}
  @doc """
  Flush collection

  Sends Sonic command: `FLUSHC <collection>`
  """
  def flush(conn, collection) do
    ~s[FLUSHC #{collection}]
    |> (&send_flush_request(conn, &1)).()
  end

  @spec flush(pid(), String.t(), String.t()) :: :ok | {:error, any} | {:ok, binary}
  @doc """
  Flush bucket in a collection

  Sends Sonic command: `FLUSHB <collection> <bucket>`
  """
  def flush(conn, collection, bucket) do
    ~s[FLUSHB #{collection} #{bucket}]
    |> (&send_flush_request(conn, &1)).()
  end

  @spec flush(pid(), String.t(), String.t(), String.t()) :: :ok | {:error, any} | {:ok, binary}
  @doc """
  Flush object in a collection's bucket.

  Sends Sonic command: `FLUSHO <collection> <bucket> <object>`
  """
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
