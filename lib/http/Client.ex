defmodule Http.Client do
  use Http.Chor.Chorex, :client

  def get_headers() do
    receive do
      # This has to come in from elsewhere
	  {:socket, s} ->
        read_headers(s)
    end
  end

  def get_body(_max_length) do
  end

  def finish_request(nil) do
	# close request
  end

  #
  # Helper functions
  #

  def read_headers(sock) do
    # ...
  end
end
