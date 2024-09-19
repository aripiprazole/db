defmodule DbTest do
  use ExUnit.Case
  doctest Db.Db

  test "sets value" do
    pid = spawn(Db.Db, :loop, [])

    send(pid, {self(), {:ok, "SET x 10"}})
    assert_receive {:ok, [false, {:number, 10}]}, 100
  end

  test "sets value twice" do
    pid = spawn(Db.Db, :loop, [])

    send(pid, {self(), {:ok, "SET x 10"}})
    send(pid, {self(), {:ok, "SET x 10"}})
    assert_receive {:ok, [false, {:number, 10}]}, 100
    assert_receive {:ok, [true, {:number, 10}]}, 100
  end

  test "gets value" do
    pid = spawn(Db.Db, :loop, [])

    send(pid, {self(), {:ok, "GET x"}})
    assert_receive {:ok, nil}, 100
  end

  test "sets and gets value" do
    pid = spawn(Db.Db, :loop, [])

    send(pid, {self(), {:ok, "SET x 10"}})
    send(pid, {self(), {:ok, "GET x"}})
    assert_receive {:ok, [false, {:number, 10}]}, 100
    assert_receive {:ok, {:number, 10}}, 100
  end

  test "begin at level 0" do
    pid = spawn(Db.Db, :loop, [])

    send(pid, {self(), {:ok, "BEGIN"}})
    send(pid, {self(), {:ok, "SET x 10"}})
    send(pid, {self(), {:ok, "GET x"}})
    assert_receive {:ok, {:number, 1}}, 100
    assert_receive {:ok, [false, {:number, 10}]}, 100
    assert_receive {:ok, {:number, 10}}, 100
  end

  test "begin at level 1" do
    pid = spawn(Db.Db, :loop, [])

    send(pid, {self(), {:ok, "BEGIN"}})
    send(pid, {self(), {:ok, "SET x 10"}})
    send(pid, {self(), {:ok, "GET x"}})
    send(pid, {self(), {:ok, "BEGIN"}})
    send(pid, {self(), {:ok, "SET y 20"}})
    assert_receive {:ok, {:number, 1}}, 100
    assert_receive {:ok, [false, {:number, 10}]}, 100
    assert_receive {:ok, {:number, 10}}, 100
    assert_receive {:ok, {:number, 2}}, 100
    assert_receive {:ok, [false, {:number, 20}]}, 100
  end

  test "commit" do
    pid = spawn(Db.Db, :loop, [])

    send(pid, {self(), {:ok, "BEGIN"}})
    send(pid, {self(), {:ok, "SET x 10"}})
    send(pid, {self(), {:ok, "GET x"}})
    send(pid, {self(), {:ok, "BEGIN"}})
    send(pid, {self(), {:ok, "SET y 20"}})
    send(pid, {self(), {:ok, "COMMIT"}})
    send(pid, {self(), {:ok, "GET y"}})
    assert_receive {:ok, {:number, 1}}, 100
    assert_receive {:ok, [false, {:number, 10}]}, 100
    assert_receive {:ok, {:number, 10}}, 100
    assert_receive {:ok, {:number, 2}}, 100
    assert_receive {:ok, [false, {:number, 20}]}, 100
    assert_receive {:ok, {:number, 1}}, 100
    assert_receive {:ok, {:number, 20}}, 100
  end

  test "rollback" do
    pid = spawn(Db.Db, :loop, [])

    send(pid, {self(), {:ok, "BEGIN"}})
    send(pid, {self(), {:ok, "SET x 10"}})
    send(pid, {self(), {:ok, "GET x"}})
    send(pid, {self(), {:ok, "BEGIN"}})
    send(pid, {self(), {:ok, "SET y 20"}})
    send(pid, {self(), {:ok, "COMMIT"}})
    send(pid, {self(), {:ok, "GET y"}})
    send(pid, {self(), {:ok, "ROLLBACK"}})
    send(pid, {self(), {:ok, "GET x"}})
    send(pid, {self(), {:ok, "GET y"}})
    assert_receive {:ok, {:number, 1}}, 100
    assert_receive {:ok, [false, {:number, 10}]}, 100
    assert_receive {:ok, {:number, 10}}, 100
    assert_receive {:ok, {:number, 2}}, 100
    assert_receive {:ok, [false, {:number, 20}]}, 100
    assert_receive {:ok, {:number, 1}}, 100
    assert_receive {:ok, {:number, 20}}, 100
    assert_receive {:ok, {:number, 0}}, 100
    assert_receive {:ok, nil}, 100
    assert_receive {:ok, nil}, 100
  end
end
