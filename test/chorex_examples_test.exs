defmodule ChorexExamplesTest do
  use ExUnit.Case
  doctest ChorexExamples

  test "greets the world" do
    assert ChorexExamples.hello() == :world
  end
end
