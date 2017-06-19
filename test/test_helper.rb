ENV['RAILS_ENV'] ||= 'test'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup'
Bundler.require :default, :development
require 'second_base'
require 'active_support/test_case'
require 'active_support/testing/autorun'

if Rails.version.to_i == 4
  require 'dummy_apps/rails_four/init'
else
  require 'dummy_apps/rails_five/config/init'
end

require 'rails/test_help'
Dir['test/test_helpers/*.{rb}'].each { |f| require_relative "../#{f}" }

ActiveSupport.test_order = :random if ActiveSupport.respond_to?(:test_order)

module SecondBase
  class TestCase < ActiveSupport::TestCase

    if Rails.version.to_i == 4
      self.use_transactional_fixtures = false
    else
      self.use_transactional_tests = false
    end

    include RailsVersionHelpers,
            DummyAppHelpers,
            StreamHelpers

    setup    :delete_dummy_files
    teardown :delete_dummy_files

    private

    def establish_connection
      ActiveRecord::Base.establish_connection
      ActiveRecord::Base.connection
      SecondBase::Base.establish_connection(SecondBase.config)
      SecondBase::Base.connection
    end

  end
end
