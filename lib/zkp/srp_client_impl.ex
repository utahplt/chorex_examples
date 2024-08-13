defmodule Zkp.SrpClientImpl do
  use Zkp.SrpChor.Chorex, :srpclient

  import Zkp.SrpChor, only: [hash_things: 1]

  @impl true
  def get_id() do
	IO.gets("[Login] username: ") |> String.trim()
  end

  def hash_passwd(id, salt, passwd) do
    hash_things([id, salt, passwd])
  end

  @impl true
  def compute_secret(g, n, s, big_b, k, id) do
    passwd = IO.gets("[Login] password: ") |> String.trim()

    # a = Enum.random(2..n)
    a = 7
    big_a = :crypto.mod_pow(g, a, n) |> as_int()
    big_b = as_int(big_b)
    x = hash_passwd(id, s, passwd)
    # IO.inspect(as_int(x), label: "[client] x")
    mpow(g, x, n) |> as_int() |> IO.inspect(label: "[client] should match verif code")

    u = as_int(hash_things([big_a, big_b]))
    # u's match; x looks good

    k = as_int(k)
    big_b = as_int(big_b)
    # IO.inspect({as_int(big_b), k, g, as_int(x), a, u, n}, label: "[client] {big_b, k, g, x, a, u, n}")
    secret_k = mpow(as_int(big_b) - (k * as_int(mpow(g, x, n))), (a + u * as_int(x)), n) |> as_int()
    # IO.inspect(as_int(secret_k), label: "[client] secret_k")

    IO.puts("[client] a: #{a}, A: #{big_a}, x: #{x}, u: #{u}, k: #{k}, B: #{big_b}, secret: #{secret_k}")

    m1 = hash_things([big_a, big_b, secret_k])
    {big_a, m1, secret_k}
  end

  @impl true
  def valid_m2?(big_a, m1, k, m2) do
	hash_things([big_a, m1, k]) == m2
  end

  defdelegate mpow(a, b, c), to: :crypto, as: :mod_pow
  # defdelegate as_int(n), to: :crypto, as: :bytes_to_integer
  def as_int(n) when is_integer(n), do: n
  def as_int(n) when is_binary(n), do: :crypto.bytes_to_integer(n)

  @impl true
  def gen_verification_token(username, password, salt, g, p) do
    x = hash_things([username, salt, password])
    |> IO.inspect(label: "[client] x")
    mpow(g, x, p) |> as_int() |> IO.inspect(label: "[client] tok")
  end
end
