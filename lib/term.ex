defmodule Db.Term do
  def parse([:set, {:ident, name}, value]), do: {:set, name, parse_expr(value)}
  def parse([:get, {:ident, name}]), do: {:get, name}
  def parse([:rollback]), do: :rollback
  def parse([:begin]), do: :begin
  def parse([:commit]), do: :commit
  def parse([:set | _]), do: raise("SET <chave> <valor> - Syntax error")
  def parse([:get | _]), do: raise("GET <chave> - Syntax error")
  def parse([:rollback | _]), do: raise("ROLLBACK - Syntax error")
  def parse([:begin | _]), do: raise("BEGIN - Syntax error")
  def parse([:commit | _]), do: raise("COMMIT - Syntax error")
  def parse(_), do: raise("Syntax error")

  def parse_expr({:number, value}), do: {:number, value}
  def parse_expr({:string, value}), do: {:string, value}
  def parse_expr(true), do: true
  def parse_expr(false), do: false
  def parse_expr(nil), do: nil
  def parse_expr(_), do: raise("<valor> - Syntax error")

  def show([a, b]), do: "#{show(a)} #{show(b)}"
  def show({:number, value}), do: value
  def show({:string, value}), do: value
  def show(true), do: "TRUE"
  def show(false), do: "FALSE"
  def show(nil), do: "NIL"
end