defmodule Zkp.ZkpChor do
  import Chorex

  defchor [Prover, Verifier] do
    # ...

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
