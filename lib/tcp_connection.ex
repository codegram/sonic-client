defmodule SonicClient.TcpConnection do
  @moduledoc """
  This is the TcpConnection module, responsible to send and receive calls.
  """

  use Connection

  @doc """
  Starts connection with the Sonic server as a child process.

  Returns `{:ok, conn}`.

  Where `conn` is the PID of the client.

  ## Examples

      SonicClient.TcpConnection.open(127.0.0.1, 1491, [])
      {:ok, #PID<0.198.0>}
  """
  @spec open(String.t(), integer(), list(), integer()) :: {:error, any()} | {:ok, pid()}
  def open(host, port, opts \\ [], timeout \\ 5000) do
    {:ok, conn} = Connection.start_link(__MODULE__, {host, port, opts, timeout})

    case build_response(conn, 0, 300) do
      {:ok, _msg} -> {:ok, conn}
      error -> error
    end
  end

  @doc """
  Sends a synchronous request with command `command` to the Sonic server through the PID child.

  Returns `{:ok, response}`.

  Where response is a String with the body of the response.
  """

  @spec request(pid(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def request(conn, command) do
    case send_message(conn, command) do
      :ok -> receive_message(conn)
      error -> error
    end
  end

  def search_request(conn, command) do
    with(
      :ok <- send_message(conn, command),
      {:ok, "PENDING " <> marker} <- receive_message(conn),
      {:ok, "EVENT " <> result} <- receive_message(conn)
    ) do
      {
        :ok,
        result
        |> String.trim_leading("QUERY #{marker}")
        |> String.trim_leading("SUGGEST #{marker}")
        |> String.split(" ", trim: true)
      }
    else
      nil -> {:error, :invalid_options}
      reason -> {:error, reason}
    end
  end

  def close(conn), do: Connection.call(conn, :close)

  defp send_message(conn, message) do
    Connection.call(conn, {:send, message <> "\n"})
  end

  defp receive_message(conn, bytes \\ 0, timeout \\ 3000) do
    build_response(conn, bytes, timeout)
  end

  defp build_response(partial_responses \\ [], conn, bytes, timeout) do
    {:ok, received_bytes} = Connection.call(conn, {:recv, bytes, timeout})
    partial_response = Kernel.to_string(received_bytes)
    is_final = String.ends_with?(partial_response, "\r\n")

    case partial_response do
      "ERR" <> reason ->
        {:error, reason}

      final_partial_response when is_final ->
        {:ok, String.trim(Enum.reduce(partial_responses, final_partial_response, &(&1 <> &2)))}

      _ ->
        build_response([partial_response | partial_responses], conn, bytes, timeout)
    end
  end

  @impl true
  def init({host, port, opts, timeout}) do
    s = %{host: host, port: port, opts: opts, timeout: timeout, sock: nil}
    {:connect, :init, s}
  end

  @impl true
  def connect(
        _,
        %{sock: nil, host: host, port: port, opts: opts, timeout: timeout} = s
      ) do
    case :gen_tcp.connect(host, port, [active: false] ++ opts, timeout) do
      {:ok, sock} ->
        {:ok, %{s | sock: sock}}

      {:error, _} ->
        {:backoff, 1000, s}
    end
  end

  @impl true
  def disconnect(info, %{sock: sock} = s) do
    :ok = :gen_tcp.close(sock)

    case info do
      {:close, from} ->
        Connection.reply(from, :ok)

      {:error, :closed} ->
        "Connection closed~n"

      {:error, reason} ->
        reason = :inet.format_error(reason)
        "Connection error: ~s~n #{reason}"
    end

    {:connect, :reconnect, %{s | sock: nil}}
  end

  @impl true
  def handle_call(_, _, %{sock: nil} = s) do
    {:reply, {:error, :closed}, s}
  end

  def handle_call({:send, data}, _, %{sock: sock} = s) do
    case :gen_tcp.send(sock, data) do
      :ok ->
        {:reply, :ok, s}

      {:error, _} = error ->
        {:disconnect, error, error, s}
    end
  end

  def handle_call({:recv, bytes, timeout}, _, %{sock: sock} = s) do
    case :gen_tcp.recv(sock, bytes, timeout) do
      {:ok, _} = ok ->
        {:reply, ok, s}

      {:error, :timeout} = timeout ->
        {:reply, timeout, s}

      {:error, _} = error ->
        {:disconnect, error, error, s}
    end
  end

  def handle_call(:close, from, s) do
    {:disconnect, {:close, from}, s}
  end
end
