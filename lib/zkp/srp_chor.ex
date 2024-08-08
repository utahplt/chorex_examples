defmodule Zkp.SrpChor do
  import Chorex

  # Protocol from http://srp.stanford.edu/design.html
  defchor [SrpServer, SrpClient] do
    # Login flow
    def run() do
      with SrpClient.(id) <- SrpClient.get_id() do
        SrpClient.(id) ~> SrpServer.(id)

        with SrpServer.(cred_lookup) <- SrpServer.lookup(id) do
          if SrpServer.(cred_lookup) do
            SrpServer[L] ~> SrpClient

            with SrpServer.({{g, n, salt, tok}, b_secret}) <-
                   SrpServer.(
                     {cred_lookup, Enum.random(2..10_000_000_000_000_000_000_000_000_000)}
                   ) do
              with SrpServer.(k) <- SrpServer.(hash_things([g, n])) do
                with SrpServer.(big_b) <-
                       SrpServer.(
                         :crypto.mod_pow(:crypto.mod_pow(g, b_secret, n) + k * tok, 1, n)
                       ) do
                  SrpServer.({g, n, salt, k, big_b}) ~> SrpClient.({g, n, salt, k, big_b})

                  with SrpClient.({big_a, m1, secret}) <-
                         SrpClient.compute_secret(g, n, salt, big_b, k, id) do
                    SrpClient.({big_a, m1}) ~> SrpServer.({big_a, m1})

                    with SrpServer.(secret) <-
                           SrpServer.compute_secret(n, big_a, big_b, b_secret, tok) do
                      if SrpServer.valid_m1?(big_a, big_b, m1) do
                        SrpServer[L] ~> SrpClient
                        SrpServer.compute_m2(big_a, m1, secret) ~> SrpClient.(m2)

                        if SrpClient.valid_m2?(m2) do
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
    |> then(&:crypto.hash(:sha265, &1))
  end

  defp to_binary(thing) when is_binary(thing), do: thing
  defp to_binary(thing) when is_integer(thing), do: :binary.encode_unsigned(thing)
end
