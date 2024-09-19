defmodule EvalTest do
  use ExUnit.Case

  test "eval set command" do
    assert Db.Eval.eval({:set, "x", {:number, 10}}, %{}) ==
             {%{"x" => {:number, 10}}, :set, [false, {:number, 10}]}
  end

  test "eval get command with existing key" do
    assert Db.Eval.eval({:get, "x"}, %{"x" => {:number, 10}}) ==
             {%{"x" => {:number, 10}}, :get, {:number, 10}}
  end

  test "eval get command with non-existing key" do
    assert Db.Eval.eval({:get, "y"}, %{}) == {%{}, :get, nil}
  end

  test "eval begin command" do
    assert Db.Eval.eval(:begin, %{}) == {%{}, :begin, nil}
  end

  test "eval commit command" do
    assert Db.Eval.eval(:commit, %{}) == {%{}, :commit, nil}
  end

  test "eval rollback command" do
    assert Db.Eval.eval(:rollback, %{}) == {%{}, :rollback, nil}
  end

  test "eval set command with existing key" do
    assert Db.Eval.eval({:set, "x", {:string, "new"}}, %{"x" => {:number, 10}}) ==
             {%{"x" => {:string, "new"}}, :set, [true, {:string, "new"}]}
  end

  test "eval set command with different types" do
    assert Db.Eval.eval({:set, "x", true}, %{"x" => {:number, 10}}) ==
             {%{"x" => true}, :set, [true, true]}
  end
end
