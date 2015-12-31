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

  end



  def test_db_create_drop
    skip
    Rake::Task['db:create'].execute
    assert_equal ['base.sqlite3', 'second.sqlite3'], dummy_databases
    Rake::Task['db:drop'].execute
    assert_equal [], dummy_databases
  end

  def test_abort_if_pending
    skip
    Rake::Task['db:create'].execute
    assert_raises SystemExit do
      Rake::Task['db:abort_if_pending_migrations'].execute
    end
    Rake::Task['db:migrate:original'].execute
    assert_raises SystemExit do
      Rake::Task['db:abort_if_pending_migrations'].execute
    end
    Rake::Task['secondbase:migrate'].execute
    Rake::Task['db:abort_if_pending_migrations'].execute
  end

  def test_db_strucutre_dump_load
    skip 'Need to fix schema cache issues'
    Rake::Task['db:create'].execute
    Rake::Task['db:migrate'].execute
    Dir.chdir(DatabaseTasks.db_dir + '/..') { Rake::Task['db:structure:dump'].execute }
    structure = File.read(DatabaseTasks.db_dir + '/structure.sql')
    secondbase_structure = File.read(DatabaseTasks.db_dir + '/secondbase_structure.sql')
    assert structure.include?('CREATE TABLE "first_base_table"'), 'Structure does not have table create statement!'
    assert secondbase_structure.include?('CREATE TABLE "second_base_table"'), 'Seondbase structure does not have table create statement!'
    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Dir.chdir(DatabaseTasks.db_dir + '/..') { Rake::Task['db:structure:load'].execute }
    assert_equal ["schema_migrations", "first_base_table"], ActiveRecord::Base.connection.tables
    assert_equal ["schema_migrations", "second_base_table"], SecondBase::Base.connection.tables
  end


  private

  def assert_connection_tables(model, expected_tables)
    model.establish_connection
    tables = model.connection.tables
    expected_tables.each do |table|
      message = "Expected #{model.name} tables #{tables.inspect} to include #{table.inspect}"
      assert tables.include?(table), message
    end
  end


end
