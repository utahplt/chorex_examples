defmodule Zkp.SrpClientImpl do
  use Zkp.SrpChor.Chorex, :srpclient

  import Zkp.SrpChor, only: [hash_things: 1]

  @impl true
  def get_id() do
	IO.gets("[Login] username: ") |> String.trim()
  end

  @impl true
  def compute_secret(g, n, s, big_b, k, id) do
    passwd = IO.gets("[Login] password: ") |> String.trim()

    # a = Enum.random(2..n)
    a = 7
    big_a = :crypto.mod_pow(g, a, n)
    big_a = as_int(big_a)
    big_b = as_int(big_b)
    x = hash_things([id, s, passwd])

    u = hash_things([big_a, big_b])

    k = as_int(k)
    secret_k = mpow(as_int(big_b) - (k * as_int(mpow(g, x, n))), (a + u * as_int(x)), n)

    IO.puts("[client] a: #{a}, A: #{big_a}, x: #{x}, u: #{u}, k: #{k}, B: #{big_b}, secret: #{as_int(secret_k)}")

    m1 = hash_things([big_a, big_b, as_int(secret_k)]) |> IO.inspect(label: "[client] m1")
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
