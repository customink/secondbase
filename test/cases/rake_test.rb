require 'test_helper'

class RakeTest < SecondBase::TestCase

  def test_db_migrate
    refute_dummy_databases
    Dir.chdir(dummy_root) { `rake db:migrate` }
    # First database and schema.
    schema = File.read(dummy_schema)
    assert_match %r{version: 20141214142700}, schema
    assert_match %r{create_table "users"}, schema
    assert_match %r{create_table "posts"}, schema
    refute_match %r{create_table "comments"}, schema
    assert_connection_tables ActiveRecord::Base, ['users', 'posts']
    # Second database and schema.
    secondbase_schema = File.read(dummy_secondbase_schema)
    assert_match %r{version: 20151202075826}, secondbase_schema
    refute_match %r{create_table "users"}, secondbase_schema
    refute_match %r{create_table "posts"}, secondbase_schema
    assert_match %r{create_table "comments"}, secondbase_schema
    assert_connection_tables SecondBase::Base, ['comments']
  end

  def test_db_create
    refute_dummy_databases
    Dir.chdir(dummy_root) { `rake db:create` }
    assert_dummy_databases
  end

  def test_db_drop
    test_db_create
    Dir.chdir(dummy_root) { `rake db:drop` }
    refute_dummy_databases
  end

  def test_db_test_purge
    test_db_create
    Dir.chdir(dummy_root) { `rake db:test:purge` }
    reestablish_connection
    assert_equal [], ActiveRecord::Base.connection.tables
    assert_equal [], SecondBase::Base.connection.tables
  end

  def test_db_test_load_schema
    test_db_test_purge
    Dir.chdir(dummy_root) { `rake db:migrate` }
    Dir.chdir(dummy_root) { `rake db:test:load_schema` }
    reestablish_connection
    assert_connection_tables ActiveRecord::Base, ['users', 'posts']
    assert_connection_tables SecondBase::Base, ['comments']
  end

  private

  def reestablish_connection
    ActiveRecord::Base.establish_connection
    SecondBase::Base.establish_connection(SecondBase.config)
  end

  def assert_connection_tables(model, expected_tables)
    reestablish_connection
    tables = model.connection.tables
    expected_tables.each do |table|
      message = "Expected #{model.name} tables #{tables.inspect} to include #{table.inspect}"
      assert tables.include?(table), message
    end
  end
end
