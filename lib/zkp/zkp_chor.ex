defmodule Zkp.ZkpChor do
  import Chorex

  # Example from: https://en.wikipedia.org/wiki/Zero-knowledge_proof#Discrete_log_of_a_given_value
  defchor [Prover, Verifier] do
    def run(Verifier.(rounds)) do
      with Verifier.({p, g}) <- Verifier.gen_pg() do
        Verifier.({p, g}) ~> Prover.({p, g})
        Prover.get_id() ~> Verifier.(prover_id)
        round_loop(Prover.({get_secret(), p g}), Verifier.({get_secret_for(prover_id), p, g}), Verifier.(rounds))
      end
    end

    # I'm not sure I can actually do this because I would need a way
    # to merge the choreographies of the two branches for the
    # projection of Prover. I think I'll have to merge the two into an
    # "if" and one function, or keep a round count on both.
    def round_loop(Prover.({secret_x, p, g}), Verifier.({secret_y, p, g}), Verifier.(0)) do
      Verifier[L] ~> Prover     # implicit choice in function signature
      Verifier.(:accept)
      Prover.(:accept)
    end

    def round_loop(Prover.({secret_x, p, g}), Verifier.({secret_y, p, g}), Verifier.(rounds_left)) do
      Verifier[R] ~> Prover
      with Verifier.(good_proof?) <- round(Prover.({secret_x, p, g}), Verifier.({secret_y, p, g})) do
        if Verifier.(good_proof?) do
          Verifier[L] ~> Prover
          Verifier.(rounds_left) ~> Prover.(remaining_rounds)
          Prover.notify_progress(remaining_rounds)
          round_loop(Prover.({secret_x, p, g}), Verifier.({secret_y, p, g}), Verifier.(rounds_left - 1))
        else
          Verifier[R] ~> Prover
          Prover.(:fail)
          Verifier.(:fail)
        end
      end
    end

    def round(Prover.({secret_x, p, g}), Verifier.({secret_y, p, g})) do
      with Prover.(r) <- Prover.gen_rand(g, p) do
        Prover.(:crypto.mod_pow(g, r, p)) ~> Verifier.(c)

        with Verifier.(choice) <- Verifier.rand_request() do
          if choice == :r do
            Verifier[L] ~> Prover
            Prover.(r) ~> Verifier.(r)
            Verifier.verify_round(c, r, g, p)
          else
            Verifier[R] ~> Prover
            Prover.(rem(secret_x + r, p - 1)) ~> Verifier.(xr_modp)
            Verifier.verify_round(c, xr_modp, secret_y, g, p)
          end
        end
      end
    end
  end
end
