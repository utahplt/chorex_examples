defmodule ProjectionExample do
  import Chorex

  def show_projection() do
    quote do
      defchor [Alice, Bob] do
        def run(Bob.(title)) do
          Bob.remark("I want" <> title)
          Bob.(title) ~> Alice.(t)
          Alice.get_price(t) ~> Bob.(price)
          Bob.record(title, price)
        end
      end
    end
    |> Macro.expand_once(__ENV__)
    |> Macro.to_string()
    |> IO.puts()
  end
end
