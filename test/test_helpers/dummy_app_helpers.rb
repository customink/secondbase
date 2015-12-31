module SecondBase
  module DummyAppHelpers

    extend ActiveSupport::Concern

    included do
      teardown :teardown_files
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

    def dummy_schema
      dummy_app.root.join 'db', 'schema.rb'
    end

    def dummy_databases
      Dir.chdir(dummy_app.root.join('db')) { Dir['*.sqlite3'] }
    end

    def assert_dummy_databases
      assert_equal ['base.sqlite3', 'second.sqlite3'], dummy_databases
    end

    def refute_dummy_databases
      assert_equal [], dummy_databases
    end

    def teardown_files
      FileUtils.rm_rf dummy_schema
      dummy_databases.each { |db| FileUtils.rm_rf(db) }
    end

  end
end
