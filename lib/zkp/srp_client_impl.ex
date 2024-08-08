defmodule Zkp.SrpClientImpl do
  use Zkp.SrpChor.Chorex, :srpclient

  import Zkp.SrpChor, only: [hash_things: 1]

  @impl true
  def get_id() do
	IO.gets("[Login] username: ") |> String.trim()
  end

  def hash_passwd(id, salt, passwd) do
    :crypto.bytes_to_integer(:crypto.hash(:shasum256, "#{id}#{salt}#{passwd}"))
  end

  @impl true
  def compute_secret(g, n, s, big_b, k, id) do
    passwd = IO.gets("[Login] password: ") |> String.trim()

    a = Enum.random(2..n)
    big_a = :crypto.mod_pow(g, a, n)
    x = hash_passwd(id, s, passwd)

    u = :crypto.bytes_to_integer(hash_things([big_a, big_b]))

    secret_k = :crypto.mod_pow(big_b - :crypto.mod_pow(k * g, x, n), (a + u * x), n)

    m1 = hash_things([big_a, big_b, secret_k])
    {big_a, m1, secret_k}
  end

end
