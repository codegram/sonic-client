defmodule ElixirSonicClient.Pinger do
  @moduledoc """
  Draft module to test connection
  """

  use Connection

  defp recv(responses \\ [], connection, bytes, timeout) do
    with {:ok, response} <- Connection.call(connection, {:recv, bytes, timeout}) do
      if String.ends_with?(response, "\r\n") do
        {:ok, Enum.reduce(responses, response, &(&1 <> &2))}
      else
        recv([response | responses], connection, bytes, timeout)
      end
    else
      error -> error
    end
  end

  def handle_call({:recv, bytes, timeout}, _, %{sock: sock} = s) do
    case :gen_tcp.recv(sock, bytes, timeout) do
      {:ok, _} = ok ->
        {:reply, ok, s}

      {:error, :timeout} = error ->
        {:reply, error, s}

      {:error, _} = error ->
        {:disconnect, error, error, s}
    end
  end

  def init({host, port, opts, timeout}) do
    s = %{host: host, port: port, opts: opts, timeout: timeout, sock: nil}
    {:connect, :init, s}
  end

  def ping do
    host = {127, 0, 0, 1}
    port = 1491
    args = [mode: :binary, packet: :line]
    timeout = 1000

    {:ok, connection} = Connection.start_link(__MODULE__, {host, port, args, timeout})
    {:ok, response} = recv([], connection, 0, 3000)

    case String.trim(response) do
      "ERR " <> reason -> {:error, reason}
      response -> {:ok, response}
    end
  end
end
