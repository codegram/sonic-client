defmodule SonicClient.TcpConnection do
  @moduledoc """
  This is the TcpConnection module, responsible to send and receive calls.
  """

  alias __MODULE__

  use Connection

  @spec start_link(any, any, any, any) :: :ignore | {:error, any} | {:ok, pid}
  @doc """
  Starts connection with the tcp server.

  Returns `{:ok, conn}`.

  ## Examples

      SonicClient.TcpConnection.start_link(127.0.0.1, 1491, [])
      {:ok, #PID<0.198.0>}
  """
  def start_link(host, port, opts, timeout \\ 5000) do
    Connection.start_link(__MODULE__, {host, port, opts, timeout})
  end

  def open(host, port, opts, timeout \\ 5000) do
    {:ok, conn} = Connection.start_link(__MODULE__, {host, port, opts, timeout})

    case build_response(conn, 0, 300) do
      {:ok, _msg} -> {:ok, conn}
      error -> error
    end
  end

  @doc """
  Sends a message to the tcp server.

  Returns `:ok`.

  ## Examples

      .TcpConnection.send(conn, "start search password")
      :ok
  """
  def send(conn, command) do
    # IO.puts("Sending \"#{data}\"")
    Connection.call(conn, {:send, command <> "\n"})
  end

  @doc """
  Receives message from the tcp server.

  Returns `{:ok, response}`.

  ## Examples

      .TcpConnection.recv(conn)
      {:ok, 'CONNECTED <sonic-server v1.3.0>\r\n'}
  """
  def recv(conn, bytes \\ 0, timeout \\ 3000) do
    response = build_response(conn, bytes, timeout)

    # if match?({:ok, _}, response) do
    #   {:ok, msg} = response
    #   IO.puts("Received \"#{msg}\"")
    # end

    response
  end

  defp build_response(partial_responses \\ [], conn, bytes, timeout) do
    {:ok, received_bytes} = Connection.call(conn, {:recv, bytes, timeout})
    partial_response = Kernel.to_string(received_bytes)
    is_finished = String.ends_with?(partial_response, "\r\n")

    case String.trim(partial_response) do
      "ERR" <> reason ->
        {:error, reason}

      response when is_finished ->
        {:ok, Enum.reduce(partial_responses, response, &(&1 <> &2))}

      _ ->
        build_response([partial_response | partial_responses], conn, bytes, timeout)
    end
  end

  def request(conn, command) do
    case TcpConnection.send(conn, command) do
      :ok -> TcpConnection.recv(conn)
      error -> error
    end
  end

  def close(conn), do: Connection.call(conn, :close)

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
