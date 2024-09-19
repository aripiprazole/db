defmodule DbTest do
  use ExUnit.Case
  doctest Db

  test "sets value" do
    Db.Db.loop(self(), %{}, [], 0)
  end
end
