defmodule TermTest do
  use ExUnit.Case

  test "parse set ok" do
    assert Db.Term.parse([:set, {:ident, "x"}, {:number, 10}]) == {:set, "x", {:number, 10}}
  end

  test "parse get ok" do
    assert Db.Term.parse([:get, {:ident, "x"}]) == {:get, "x"}
  end

  test "parse begin ok" do
    assert Db.Term.parse([:begin]) == :begin
  end

  test "parse commit ok" do
    assert Db.Term.parse([:commit]) == :commit
  end

  test "parse rollback ok" do
    assert Db.Term.parse([:rollback]) == :rollback
  end

  test "parse set syntax error" do
    assert_raise RuntimeError, "SET <chave> <valor> - Syntax error", fn ->
      Db.Term.parse([:set])
    end
  end

  test "parse get syntax error" do
    assert_raise RuntimeError, "GET <chave> - Syntax error", fn ->
      Db.Term.parse([:get])
    end
  end

  test "parse begin syntax error" do
    assert_raise RuntimeError, "BEGIN - Syntax error", fn ->
      Db.Term.parse([:begin, :extra])
    end
  end

  test "parse commit syntax error" do
    assert_raise RuntimeError, "COMMIT - Syntax error", fn ->
      Db.Term.parse([:commit, :extra])
    end
  end

  test "parse rollback syntax error" do
    assert_raise RuntimeError, "ROLLBACK - Syntax error", fn ->
      Db.Term.parse([:rollback, :extra])
    end
  end

  test "parse unknown command" do
    assert_raise RuntimeError, "Syntax error", fn ->
      Db.Term.parse([:unknown])
    end
  end

  test "parse expr number" do
    assert Db.Term.parse_expr({:number, 10}) == {:number, 10}
  end

  test "parse expr string" do
    assert Db.Term.parse_expr({:string, "hello"}) == {:string, "hello"}
  end

  test "parse expr boolean" do
    assert Db.Term.parse_expr(true) == true
    assert Db.Term.parse_expr(false) == false
  end

  test "parse expr nil" do
    assert Db.Term.parse_expr(nil) == nil
  end

  test "parse expr syntax error" do
    assert_raise RuntimeError, "<valor> - Syntax error", fn ->
      Db.Term.parse_expr({:invalid, "value"})
    end
  end

  test "show number" do
    assert Db.Term.show({:number, 10}) == 10
  end

  test "show string" do
    assert Db.Term.show({:string, "hello"}) == "hello"
  end

  test "show boolean" do
    assert Db.Term.show(true) == "TRUE"
    assert Db.Term.show(false) == "FALSE"
  end

  test "show nil" do
    assert Db.Term.show(nil) == "NIL"
  end

  test "show list" do
    assert Db.Term.show([{:number, 10}, {:string, "hello"}]) == "10 hello"
  end
end
