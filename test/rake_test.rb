require 'test_helper'

class RakeTest < Minitest::Unit::TestCase
  include RakeTestSetup

  def setup
    setup_rake
    ENV["VERBOSE"] = 'false'
  end

  def teardown
    clean_artifacts
  end

  def test_db_create_drop
    Rake::Task['db:create'].execute
    assert_databases_present
    Rake::Task['db:drop'].execute
    assert_databases_absent
  end

  def test_migrate
    Rake::Task['db:create'].execute
    assert_equal [], ActiveRecord::Base.connection.tables
    assert_equal [], SecondBase::Base.connection.tables

    Rake::Task['db:migrate'].execute
    assert_equal ["schema_migrations", "first_base_table"], ActiveRecord::Base.connection.tables
    assert_equal ["schema_migrations", "second_base_table"], SecondBase::Base.connection.tables
  end

  def test_abort_if_pending
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

  def clean_artifacts
    Dir.chdir(DatabaseTasks.db_dir) { FileUtils.rm(Dir['*.{sqlite3,sql}']) }
  end

  def assert_databases_present
    databases = Dir.chdir(DatabaseTasks.db_dir) { Dir['*.sqlite3'] }
    assert_equal ['firstbase.sqlite3', 'secondbase.sqlite3'], databases
  end

  def assert_databases_absent
    databases = Dir.chdir(DatabaseTasks.db_dir) { Dir['*.sqlite3'] }
    assert_equal [], databases
  end
end
