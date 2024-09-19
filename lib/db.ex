defmodule Db.Db do
  @moduledoc """
  Database CLI
  """

  @spec rollback(any(), nonempty_maybe_improper_list()) :: {any(), any(), any()}
  def rollback(_, []), do: raise("Not in a transaction context")
  def rollback(desired_lvl, xs) when desired_lvl < 0, do: rollback(0, xs)

  def rollback(desired_lvl, [{lvl, db} | rest]) do
    if lvl == desired_lvl do
      {desired_lvl, db, rest}
    else
      rollback(desired_lvl, rest)
    end
  end

  @spec loop() :: no_return()
  def loop(), do: loop(%{}, [], 0)

  @spec loop(any(), list(), integer()) :: no_return()
  def loop(_, _, lvl) when lvl < 0, do: raise("Invalid transaction level")

  @spec loop(any(), list(), integer()) :: no_return()
  def loop(db, snapshots, lvl) do
    receive do
      {from, {:ok, input}} ->
        try do
          {db, kind, result} =
            input
            |> Db.Lexer.lex()
            |> Db.Term.parse()
            |> Db.Eval.eval(db)

          case {kind, result} do
            {:begin, _} ->
              lvl = lvl + 1
              send(from, {:ok, {:number, lvl}})
              loop(db, [{lvl - 1, db} | snapshots], lvl)

            {:commit, _} ->
              lvl = lvl - 1
              send(from, {:ok, {:number, lvl}})
              loop(db, snapshots, lvl)

            {:rollback, _} ->
              lvl = lvl - 1
              {lvl, db, snapshots} = rollback(lvl, snapshots)
              send(from, {:ok, {:number, lvl}})
              loop(db, snapshots, lvl)

            _ ->
              send(from, {:ok, result})
              loop(db, snapshots, lvl)
          end
        rescue
          err in RuntimeError ->
            send(from, {:err, err.message})
            loop(db, snapshots, lvl)
        catch
          err ->
            send(from, {:err, err})
            loop(db, snapshots, lvl)
        end
    end
  end

  def handle(pid) do
    IO.write("> ")
    send(pid, {self(), {:ok, IO.read(:stdio, :line)}})

    receive do
      {:ok, value} -> IO.puts(Db.Term.show(value))
      {:err, message} -> IO.puts("ERR \"#{message}\"")
    end

    handle(pid)
  end

  def main(_) do
    input = spawn(Db.Db, :loop, [])
    handle(input)
  end
end
