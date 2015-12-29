require 'test_helper'
require 'support/activerecord_rake_support'
require 'secondbase/tasks'
require 'pry'

class RakeTest < Minitest::Unit::TestCase
  include RakeTestSetup

  def setup
    setup_rake
  end

  def test_db_create
    Rake::Task['db:create'].invoke
  end
end
