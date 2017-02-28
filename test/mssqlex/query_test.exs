defmodule Mssqlex.QueryTest do
  use ExUnit.Case, async: true

  alias Mssqlex.Result

  setup_all do
    {:ok, pid} = Mssqlex.start_link([])
    Mssqlex.query(pid, "DROP DATABASE query_test;", [])
    {:ok, _, _} = Mssqlex.query(pid, "CREATE DATABASE query_test;", [])

    {:ok, [pid: pid]}
  end

  test "simple select", %{pid: pid} do
    assert {:ok, _, %Result{}} =
      Mssqlex.query(pid, "CREATE TABLE query_test.dbo.simple_select (name varchar(50));", [])

    assert {:ok, _, %Result{num_rows: 1}} =
      Mssqlex.query(pid, ["INSERT INTO query_test.dbo.simple_select VALUES ('Steven');"], [])

    assert {:ok, _, %Result{num_rows: 1, rows: [["Steven"]]}} =
      Mssqlex.query(pid, "SELECT * FROM query_test.dbo.simple_select;", [])
  end

  test "parametrized queries", %{pid: pid} do
    assert {:ok, _, %Result{}} =
      Mssqlex.query(pid, "CREATE TABLE query_test.dbo.parametrized_query (id int, name varchar(50), joined datetime2);", [])

    assert {:ok, _, %Result{num_rows: 1}} =
      Mssqlex.query(pid, ["INSERT INTO query_test.dbo.parametrized_query VALUES (?, ?, ?);"], [{:sql_integer, [1]}, {{:sql_varchar, 50}, ["Jae"]}, {{:sql_wvarchar, 27}, ["2017-01-01 12:01:01.3450000"]}])

    assert {:ok, _, %Result{num_rows: 1, rows: [[1, "Jae", {{2017, 1, 1}, {12, 1, 1}}]]}} =
      Mssqlex.query(pid, "SELECT * FROM query_test.dbo.parametrized_query;", [])
  end
end
