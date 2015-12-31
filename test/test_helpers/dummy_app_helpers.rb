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
      dummy_app.root.join('tmp').to_s
    end

    def dummy_schema
      dummy_app.root.join('db', 'schema.rb').to_s
    end

    def teardown_files
      FileUtils.rm_rf(dummy_schema)
    end

  end
end
