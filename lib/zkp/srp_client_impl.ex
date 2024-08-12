defmodule Zkp.SrpClientImpl do
  use Zkp.SrpChor.Chorex, :srpclient

  import Zkp.SrpChor, only: [hash_things: 1]

  @impl true
  def get_id() do
	IO.gets("[Login] username: ") |> String.trim()
  end

  def hash_passwd(id, salt, passwd) do
    as_int(:crypto.hash(:sha256, "#{id}#{salt}#{passwd}"))
  end

  @impl true
  def compute_secret(g, n, s, big_b, k, id) do
    passwd = IO.gets("[Login] password: ") |> String.trim()

    a = Enum.random(2..n)
    big_a = :crypto.mod_pow(g, a, n)
    x = hash_passwd(id, s, passwd)

    u = as_int(hash_things([big_a, big_b]))

    k = as_int(k)
    secret_k = mpow(as_int(big_b) - as_int(mpow(k * g, x, n)), (a + u * x), n)

    m1 = hash_things([big_a, big_b, secret_k])
    {big_a, m1, secret_k}
  end

  @impl true
  def valid_m2?(big_a, m1, k, m2) do
	hash_things([big_a, m1, k]) == m2
  end

  defdelegate mpow(a, b, c), to: :crypto, as: :mod_pow
  defdelegate as_int(n), to: :crypto, as: :bytes_to_integer

  @impl true
  def gen_verification_token(username, password, salt, g, p) do
    x = hash_things([username, salt, password])
    mpow(g, x, p)
  end
end
