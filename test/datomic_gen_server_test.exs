defmodule DatomicGenServerTest do
  use ExUnit.Case, async: false
  
  setup_all do
    # Need a long timeout to let the JVM start.
    DatomicGenServer.start_link("datomic:mem://test", true, 20_000)
    :ok
  end
  
  test "can issue Datomic queries" do
    query = "[:find ?c :where [?c :db/doc \"Some docstring that shouldn't be in the database\"]]"
    result = DatomicGenServer.q(query)
    assert {:ok, "\#{}\n"} == result
    second_result = DatomicGenServer.q(query)
    assert {:ok, "\#{}\n"} == second_result
  end
  
  test "can execute Datomic transactions" do
    data_to_add = """
      [ { :db/id #db/id[:db.part/db]
          :db/ident :person/name
          :db/valueType :db.type/string
          :db/cardinality :db.cardinality/one
          :db/doc \"A person's name\"
          :db.install/_attribute :db.part/db}]
    """
    {:ok, transaction_result} = DatomicGenServer.transact(data_to_add)
    assert Regex.match?(~r/:db-before \{:basis-t \d+/, transaction_result)
    assert Regex.match?(~r/:db-after \{:basis-t \d+/, transaction_result)
    assert Regex.match?(~r/:tx-data \[\{:a \d+/, transaction_result)
    assert Regex.match?(~r/:tempids \{/, transaction_result)

    query = "[:find ?c :where [?c :db/doc \"A person's name\"]]"
    {:ok, result_str} = DatomicGenServer.q(query)
    assert Regex.match?(~r/\#\{\[\d+\]\}\n/, result_str)
  end

  test "can ask for an entity" do
    data_to_add = """
      [ {:db/id #db/id[:db.part/db]
         :db/ident :person/email
         :db/valueType :db.type/string
         :db/cardinality :db.cardinality/one
         :db/doc \"A person's email\"
         :db.install/_attribute :db.part/db} ]
    """
    {:ok, _} = DatomicGenServer.transact(data_to_add)

    all_attributes = "{:db/ident :person/email, :db/valueType :db.type/string, :db/cardinality :db.cardinality/one, :db/doc \"A person's email\"}\n"
    {:ok, entity_result} = DatomicGenServer.entity(":person/email")
    assert all_attributes == entity_result

    {:ok, entity_result2} = DatomicGenServer.entity(":person/email", :all)
    assert all_attributes == entity_result2

    {:ok, entity_result3} = DatomicGenServer.entity(":person/email", [:"db/valueType", :"db/doc"])
    assert "{:db/valueType :db.type/string, :db/doc \"A person's email\"}\n" == entity_result3
     
    {:ok, entity_result4} = DatomicGenServer.entity("[:db/ident :person/email]", [:"db/cardinality"])
    assert "{:db/cardinality :db.cardinality/one}\n" == entity_result4
  end
  
  test "Handles garbled queries" do
    query = "[:find ?c :wh?ere]"
    {:error, query_result} = DatomicGenServer.q(query)
    assert Regex.match?(~r/Exception/, query_result)
  end
  
  test "Handles garbled transactions" do
    data_to_add = """
      [ { :db/ii #db/foo[:db.part/db]
    """
    {:error, transaction_result} = DatomicGenServer.transact(data_to_add)
    assert Regex.match?(~r/Exception/, transaction_result)
  end
end
