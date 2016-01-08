require 'test_helper'

class RakeTest < SecondBase::TestCase

  def test_db_migrate
    run_db_create
    run_db_migrate
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
    run_db_create
    assert_dummy_databases
  end

  def test_db_drop
    run_db_create
    run_db_drop
    refute_dummy_databases
  end

  def test_db_test_purge
    run_db_create
    assert_dummy_databases
    run_db_purge
    reestablish_connection
    assert_equal [], ActiveRecord::Base.connection.tables
    assert_equal [], SecondBase::Base.connection.tables
  end

  def test_db_test_load_schema
    run_db_create
    assert_dummy_databases
    run_db_purge
    run_db_migrate
    Dir.chdir(dummy_root) { `rake db:test:load_schema` }
    reestablish_connection
    assert_connection_tables ActiveRecord::Base, ['users', 'posts']
    assert_connection_tables SecondBase::Base, ['comments']
  end

  def test_abort_if_pending
    run_db_create
    run_db_migrate
    assert_equal "", run_db_pending_migrations
    FileUtils.touch(dummy_migration)
    assert_match /run.*db:migrate.*try again/i, run_db_pending_migrations
  end

  def test_db_test_load_structure
    run_db_create
    assert_dummy_databases
    run_db_purge
    Dir.chdir(dummy_root) { `env SCHEMA_FORMAT=sql rake db:migrate` }
    Dir.chdir(dummy_root) { `rake db:test:load_structure` }
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

  def run_db_create
    Dir.chdir(dummy_root) { `rake db:create` }
  end

  def run_db_purge
    Dir.chdir(dummy_root) { `rake db:test:purge` }
  end

  def run_db_migrate
    Dir.chdir(dummy_root) { `rake db:migrate` }
  end

  def run_db_pending_migrations
    capture(:stderr) { Dir.chdir(dummy_root) { `rake db:abort_if_pending_migrations` } }
  end

  def run_db_drop
    Dir.chdir(dummy_root) { `rake db:drop` }
  end

end
