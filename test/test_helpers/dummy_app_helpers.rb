module SecondBase
  module DummyAppHelpers

    extend ActiveSupport::Concern

    included do
      setup    :delete_dummy_files
      teardown :delete_dummy_files
    end

    private

    def dummy_app
      ::Dummy::Application
    end

    def dummy_root
      dummy_app.root
    end

    def dummy_config
      dummy_app.config
    end

    def dummy_tmp
      dummy_app.root.join 'tmp'
    end

    def dummy_db
      dummy_app.root.join 'db'
    end

    def dummy_schema
      dummy_db.join 'schema.rb'
    end

    def dummy_databases
      Dir.chdir(dummy_db) { Dir['*.sqlite3'] }
    end

    def assert_dummy_databases
      assert_equal ['base.sqlite3', 'second.sqlite3'], dummy_databases
    end

    def refute_dummy_databases
      assert_equal [], dummy_databases
    end

    def delete_dummy_files
      FileUtils.rm_rf dummy_schema
      Dir.chdir(dummy_db) { dummy_databases.each { |db| FileUtils.rm_rf(db) } }
    end

  end
end
