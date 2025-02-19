defmodule Http.Client do
  use Http.Chor.Chorex, :client

  @impl true
  def get_headers() do
    receive do
      # This has to come in from elsewhere
      {:socket, s} ->
        read_headers(s)
    end
  end

  @impl true
  def get_body(_max_length) do
  end

  @impl true
  def finish_request(nil) do
    # close request
  end

  #
  # Helper functions
  #

  def read_headers(_sock) do
    # ...
  end
end
