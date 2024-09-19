defmodule Db.Eval do
  def eval({:set, name, value}, db) do
    if db[name] do
      {Map.put(db, name, value), :set, [true, value]}
    else
      {Map.put(db, name, value), :set, [false, value]}
    end
  end

  def eval({:get, name}, db), do: {db, :get, db[name]}
  def eval(:begin, db), do: {db, :begin, nil}
  def eval(:commit, db), do: {db, :commit, nil}
  def eval(:rollback, db), do: {db, :rollback, nil}
end
