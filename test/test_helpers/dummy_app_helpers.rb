module SecondBase
  module DummyAppHelpers

    extend ActiveSupport::Concern

    private

    def dummy_app
      ::Dummy::Application
    end

    def dummy_tmp
      dummy_app.root.join('tmp').to_s
    end

    def dummy_config
      dummy_app.config
    end

  end
end
