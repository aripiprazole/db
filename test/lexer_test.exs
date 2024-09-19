defmodule LexerTest do
  use ExUnit.Case

  test "lex empty string" do
    assert Db.Lexer.lex("") == []
  end

  test "lex whitespace" do
    assert Db.Lexer.lex("   \t\n  ") == []
  end

  test "lex SET command" do
    assert Db.Lexer.lex("SET x 10") == [:set, {:ident, "x"}, {:number, 10}]
  end

  test "lex GET command" do
    assert Db.Lexer.lex("GET x") == [:get, {:ident, "x"}]
  end

  test "lex BEGIN command" do
    assert Db.Lexer.lex("BEGIN") == [:begin]
  end

  test "lex COMMIT command" do
    assert Db.Lexer.lex("COMMIT") == [:commit]
  end

  test "lex ROLLBACK command" do
    assert Db.Lexer.lex("ROLLBACK") == [:rollback]
  end

  test "lex string value" do
    assert Db.Lexer.lex("SET x \"hello world\"") == [
             :set,
             {:ident, "x"},
             {:string, "hello world"}
           ]
  end

  test "lex boolean values" do
    assert Db.Lexer.lex("SET x TRUE") == [:set, {:ident, "x"}, true]
    assert Db.Lexer.lex("SET y FALSE") == [:set, {:ident, "y"}, false]
  end

  test "lex NIL value" do
    assert Db.Lexer.lex("SET x NIL") == [:set, {:ident, "x"}, nil]
  end

  test "lex with extra whitespace" do
    assert Db.Lexer.lex("  SET   x   10  ") == [:set, {:ident, "x"}, {:number, 10}]
  end

  test "lex invalid input" do
    assert_raise RuntimeError, "Lexical error", fn ->
      Db.Lexer.lex("$@*$ASSA*F")
    end
  end
end
