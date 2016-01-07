ENV['RAILS_ENV'] ||= 'test'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup'
Bundler.require :default, :test
require 'second_base'
require 'active_support/test_case'
require 'active_support/testing/autorun'
require 'dummy_app/init'
require 'rails/test_help'
require 'test_helpers/rails_version_helpers'
require 'test_helpers/dummy_app_helpers'

ActiveSupport.test_order = :random if ActiveSupport.respond_to?(:test_order)

module SecondBase
  class TestCase < ActiveSupport::TestCase

    self.use_transactional_fixtures = false

    include RailsVersionHelpers,
            DummyAppHelpers

    setup    :delete_dummy_files
    teardown :delete_dummy_files


  end
end
