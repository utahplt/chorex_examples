defmodule Zkp.ZkpOldChor do
  # import Chorex

  # # Example from: https://en.wikipedia.org/wiki/Zero-knowledge_proof#Discrete_log_of_a_given_value
  # defchor [ProverOld, VerifierOld] do
  #   def run(VerifierOld.(rounds)) do
  #     with VerifierOld.({p, g}) <- VerifierOld.gen_pg() do
  #       VerifierOld.({p, g}) ~> ProverOld.({p, g})
  #       ProverOld.get_id() ~> VerifierOld.(prover_id)
  #       round_loop(ProverOld.({get_secret(), p g}), VerifierOld.({get_secret_for(prover_id), p, g}), VerifierOld.(rounds))
  #     end
  #   end

  #   def round_loop(ProverOld.({secret_x, p, g}), VerifierOld.({secret_y, p, g}), VerifierOld.(rounds_left)) do
  #     if VerifierOld.(rounds_left == 0) do
  #       VerifierOld[L] ~> ProverOld
  #       VerifierOld.(:accept)
  #       ProverOld.(:accept)
  #     else
  #       VerifierOld[R] ~> ProverOld
  #       with VerifierOld.(good_proof?) <- round(ProverOld.({secret_x, p, g}), VerifierOld.({secret_y, p, g})) do
  #         if VerifierOld.(good_proof?) do
  #           VerifierOld[L] ~> ProverOld
  #           VerifierOld.(rounds_left) ~> ProverOld.(remaining_rounds)
  #           ProverOld.notify_progress(remaining_rounds)
  #           round_loop(ProverOld.({secret_x, p, g}), VerifierOld.({secret_y, p, g}), VerifierOld.(rounds_left - 1))
  #         else
  #           VerifierOld[R] ~> ProverOld
  #           ProverOld.(:fail)
  #           VerifierOld.(:fail)
  #         end
  #       end
  #     end
  #   end

  #   def round(ProverOld.({secret_x, p, g}), VerifierOld.({secret_y, p, g})) do
  #     with ProverOld.(r) <- ProverOld.gen_rand(g, p) do
  #       ProverOld.(:crypto.mod_pow(g, r, p)) ~> VerifierOld.(c)

  #       with VerifierOld.(choice) <- VerifierOld.rand_request() do
  #         if choice == :r do
  #           VerifierOld[L] ~> ProverOld
  #           ProverOld.(r) ~> VerifierOld.(r)
  #           VerifierOld.verify_round(c, r, g, p)
  #         else
  #           VerifierOld[R] ~> ProverOld
  #           ProverOld.(rem(secret_x + r, p - 1)) ~> VerifierOld.(xr_modp)
  #           VerifierOld.verify_round(c, xr_modp, secret_y, g, p)
  #         end
  #       end
  #     end
  #   end
  # end
end
