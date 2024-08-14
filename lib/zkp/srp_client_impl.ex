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

    a = Enum.random(2..n)
    big_a = mpow(g, a, n)
    x = hash_things([id, s, passwd])
    u = hash_things([big_a, big_b])

    # Add n here because Elixir doesn't have a modular subtraction
    # function; when k*g^x > B and therefore B-k*g^x is negative, it
    # messes up modular exponentiation.
    secret_k =
      mpow(
        (n + as_int(big_b)) - rem(as_int(k) * as_int(mpow(g, x, n)), n),
        a + as_int(u) * as_int(x),
        n
      )

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
