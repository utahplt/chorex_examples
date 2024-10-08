defmodule Zkp.ZkpChor do
  import Chorex

  defchor [Prover, Verifier] do
    # Registration flow
    def run(Prover.(username), Prover.(password), Verifier.(:register)) do
      Verifier.get_params() ~> Prover.({g, p})
      with Prover.(token) <- Prover.gen_verification_token(username, password, g, p) do
        Prover.({username, token}) ~> Verifier.({id, token})
        if Verifier.register(id, token) do
          Verifier[L] ~> Prover
          Verifier.({:ok, id})
          Prover.(:ok)
        else
          Verifier[R] ~> Prover
          Verifier.(:failed)
          Prover.(:failed)
        end
      end
    end

    # Authentication flow
    def run(Verifier.(rounds)) do
      # Prover sends username to verifier
      with Prover.(username) <- Prover.get_ident() do
        Prover.(username) ~> Verifier.(ident)

        # Prover looks up authentication parameters; y is validation key
        with Verifier.(creds) <- Verifier.lookup(ident) do
          if Verifier.(creds) do
            Verifier[L] ~> Prover
            with Verifier.({y, p, g}) <- Verifier.(creds) do
              Verifier.({p, g}) ~> Prover.({p, g})

              round_loop(Verifier.({p, g, y}), Verifier.(rounds), Prover.({p, g, get_secret(username)}))
            end
          else
            Verifier[R] ~> Prover
            Verifier.(:bad_username)
            Prover.(:bad_username)
          end
        end
      end
    end

    # y is the validation token, x is the client secret
    def round_loop(Verifier.({p, g, y}), Verifier.(rounds), Prover.({p, g, x})) do
      if Verifier.(rounds <= 0) do
        Verifier[L] ~> Prover
        Verifier.(:accept)
        Prover.(:accept)
      else
        Verifier[R] ~> Prover

        with Verifier.(good_proof?) <- do_round(Verifier.({p, g, y}), Prover.({p, g, x})) do
          if Verifier.(good_proof?) do
            Verifier[L] ~> Prover
            Verifier.(rounds) ~> Prover.(remaining_rounds)
            Prover.notify_progress(remaining_rounds)
            round_loop(Verifier.({p, g, y}), Verifier.(rounds - 1), Prover.({p, g, x}))
          else
            Verifier[R] ~> Prover
            Verifier.(:reject)
            Prover.(:fail)
          end
        end
      end
    end

    def do_round(Verifier.({p, g, y}), Prover.({p, g, x})) do
      with Prover.(r) <- Prover.(Enum.random(2..p)) do
        Prover.(:crypto.mod_pow(g, r, p)) ~> Verifier.(c)

        with Verifier.(choice) <- Verifier.challenge_type() do
          if Verifier.(choice == :r) do
            Verifier[L] ~> Prover
            Prover.(r) ~> Verifier.(r)
            Verifier.verify_round(c, r, p, g)
          else
            Verifier[R] ~> Prover
            Prover.(rem(:crypto.bytes_to_integer(x) + r, p - 1)) ~> Verifier.(xr_modp)
            Verifier.verify_round(c, xr_modp, y, p, g)
          end
        end
      end
    end
  end
end
