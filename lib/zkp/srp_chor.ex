defmodule Zkp.SrpChor do
  import Chorex

  # Protocol from http://srp.stanford.edu/design.html
  defchor [SrpServer, SrpClient] do
    # Registration flow
    def run(SrpClient.({username, password}), SrpServer.(:register)) do
      SrpServer.get_params() ~> SrpClient.({salt, g, n})

      with SrpClient.(v) <- SrpClient.gen_verification_token(username, password, salt, g, n) do
        SrpClient.({username, salt, v}) ~> SrpServer.({username, salt, v})

        if SrpServer.register(username, salt, v) do
          SrpServer[L] ~> SrpClient
          SrpServer.({:registered, username})
          SrpClient.(:registered)
        else
          SrpServer[R] ~> SrpClient
          SrpServer.({:error, :no_registration, username})
          SrpClient.({:error, :no_registration})
        end
      end
    end

    # Login flow
    def run() do
      with SrpClient.(id) <- SrpClient.get_id() do
        # Client {id} → Server
        SrpClient.(id) ~> SrpServer.(id)

        with SrpServer.(cred_lookup) <- SrpServer.lookup(id) do
          if SrpServer.(cred_lookup) do
            SrpServer[L] ~> SrpClient

            with SrpServer.({g, n, salt, tok}) <- SrpServer.(cred_lookup),
                 SrpServer.({k, b_secret, big_b}) <- SrpServer.gen_parameters(g, n, tok) do
              # Server {g, n, salt, k, B} → Client
              SrpServer.({g, n, salt, k, big_b}) ~> SrpClient.({g, n, salt, k, big_b})

              with SrpClient.({big_a, m1, secret}) <-
                     SrpClient.compute_secret(g, n, salt, big_b, k, id) do
                # Client {A, M₁} → Server
                SrpClient.({big_a, m1}) ~> SrpServer.({big_a, m1})

                with SrpServer.(secret) <-
                       SrpServer.compute_secret(n, big_a, big_b, b_secret, tok) do
                  if SrpServer.valid_m1?(big_a, big_b, secret, m1) do
                    SrpServer[L] ~> SrpClient

                    # Server M₂ → Client
                    SrpServer.compute_m2(big_a, m1, secret) ~> SrpClient.(m2)

                    if SrpClient.valid_m2?(big_a, m1, secret, m2) do
                      SrpClient[L] ~> SrpServer
                      SrpClient.({:ok, secret})
                      SrpServer.({:ok, secret})
                    else
                      SrpClient[R] ~> SrpServer
                      SrpClient.({:fail, :reject_server_digest})
                      SrpServer.({:fail, :client_rejected_digest})
                    end
                  else
                    SrpServer[R] ~> SrpClient
                    SrpServer.({:fail, :reject_client_digest})
                    SrpClient.({:fail, :server_rejected_digest})
                  end
                end
              end
            end
          else
            SrpServer[R] ~> SrpClient
            SrpServer.({:fail, :unknown_user})
            SrpClient.({:fail, :unknown_user})
          end
        end
      end
    end
  end

  def hash_things(args) do
    args
    |> Enum.map(&to_binary/1)
    |> Enum.reduce(&<>/2)
    |> then(&:crypto.hash(:sha256, &1))
  end

  defp to_binary(thing) when is_binary(thing), do: thing
  defp to_binary(thing) when is_integer(thing), do: :binary.encode_unsigned(thing)
end
