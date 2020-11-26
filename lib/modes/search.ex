defmodule SonicClient.Modes.Search do
  alias SonicClient
  alias SonicClient.TcpConnection

  def query(conn, collection, bucket, terms) do
    command = ~s(QUERY #{collection} #{bucket} "#{terms}")
    TcpConnection.search_request(conn, command)
  end
end
