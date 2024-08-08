defmodule Zkp.SrpChor do
  # import Chorex

  # # Protocol from http://srp.stanford.edu/design.html
  # defchor [SrpServer, SrpClient] do
  #   def run() do
  #     with SrpClient.(username) <- SrpClient.get_username() do
  #       SrpClient.(username) ~> SrpServer.(username) # username = I

  #       with SrpServer.({{s, v}, {n, g}}) <- SrpServer.({lookup_user(username), get_parameters()}) do
  #         SrpServer.({s, n, g}) ~> SrpClient.({s, n, g})

  #         with SrpClient.(x) <- SrpClient.hash({s, username}) do
  #           # This isn't right... where does the `a` in g^a come from?
  #           with SrpClient.(a) <- SrpClient.(:crypto.mod_pow(g, a, n)) do
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  # def new_user(username, password) do
  # end

  # def param_n(), do: 47969458769461679
  # def param_g(), do: 23
  # def param_k(), do: hash(n + g)
end
