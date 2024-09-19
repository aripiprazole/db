defmodule Db.Db do
  @moduledoc """
  Documentation for `Db`.
  """

  def rollback(_, []), do: raise("Not in a transaction context")
  def rollback(desired_lvl, xs) when desired_lvl < 0, do: rollback(0, xs)

  def rollback(desired_lvl, [{lvl, db} | rest]) do
    if lvl == desired_lvl do
      {desired_lvl, db, rest}
    else
      rollback(desired_lvl, rest)
    end
  end

  def loop(_, _, _, lvl) when lvl < 0, do: raise("Invalid transaction level")

  def loop(pid, db, snapshots, lvl) do
    IO.write("> ")

    try do
      {db, kind, result} =
        IO.read(:stdio, :line)
        |> Db.Lexer.lex()
        |> Db.Term.parse()
        |> Db.Eval.eval(db)

      case {kind, result} do
        {:begin, _} ->
          lvl = lvl + 1
          send(pid, {:ok, {:number, lvl}})
          loop(pid, db, [{lvl, db} | snapshots], lvl)

        {:commit, _} ->
          lvl = lvl - 1
          send(pid, {:ok, {:number, lvl}})
          loop(pid, db, snapshots, lvl)

        {:rollback, _} ->
          lvl = lvl - 1
          {lvl, db, snapshots} = rollback(lvl, snapshots)
          send(pid, {:ok, {:number, lvl}})
          loop(pid, db, snapshots, lvl)

        _ ->
          send(pid, result)
          loop(pid, db, snapshots, lvl)
      end
    catch
      RuntimeError, err ->
        send(pid, {:err, err})
        loop(pid, db, snapshots, lvl)

      err ->
        send(pid, {:err, err})
        loop(pid, db, snapshots, lvl)
    end
  end

  def handle() do
    receive do
      {:ok, value} -> IO.puts(Db.Term.show(value))
      {:err, message} -> IO.puts("ERR \"#{message}\"")
    end
  end

  def main do
    pid = spawn(fn -> handle() end)
    loop(pid, %{}, [], 0)
  end
end
