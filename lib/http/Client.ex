defmodule Http.Client do
  use Http.Chor.Chorex, :client

  def get_headers(), do: nil

  def get_body(_max_length) do
  end

  def finish_request(nil) do
	# close request
  end
end
