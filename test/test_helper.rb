require 'bundler'
Bundler.require :development, :test
require 'secondbase'
require 'active_support/test_case'
require 'active_support/testing/autorun'
require 'dummy_app/init'
require 'support/rails_version_helpers'

ActiveSupport.test_order = :random if ActiveSupport.respond_to?(:test_order)

module SecondBase
  class TestCase < ActiveSupport::TestCase

    include RailsVersionHelpers



  end
end
