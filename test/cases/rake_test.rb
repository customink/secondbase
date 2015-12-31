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
    assert_base_connection_tables ['users', 'posts']
    # Second database and schema.
    secondbase_schema = File.read(dummy_secondbase_schema)
    assert_match %r{version: 20151202075826}, secondbase_schema    
    refute_match %r{create_table "users"}, secondbase_schema
    refute_match %r{create_table "posts"}, secondbase_schema
    assert_match %r{create_table "comments"}, secondbase_schema
    assert_secondbase_connection_tables ['comments']
  end

  private
  
  def assert_base_connection_tables(expected_tables)
    ActiveRecord::Base.establish_connection
    assert_connection_tables(ActiveRecord::Base, expected_tables)
  end
  
  def assert_secondbase_connection_tables(expected_tables)
    SecondBase::Base.establish_connection(SecondBase.config)
    assert_connection_tables(SecondBase::Base, expected_tables)
  end

  def assert_connection_tables(model, expected_tables)
    tables = model.connection.tables
    expected_tables.each do |table|
      message = "Expected #{model.name} tables #{tables.inspect} to include #{table.inspect}"
      assert tables.include?(table), message
    end
  end
end
