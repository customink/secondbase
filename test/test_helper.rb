require 'bundler'
Bundler.require :development, :test
require 'secondbase'
require 'secondbase/model'
require 'active_support/test_case'
require 'active_support/testing/autorun'

ActiveSupport.test_order = :random if ActiveSupport.respond_to?(:test_order)

module SecondBase
  class TestCase < ActiveSupport::TestCase

  end
end
