require 'test_helper'

class OnBaseTest < SecondBase::TestCase

  setup do
    run_db :create
    run_db :migrate
    establish_connection
  end

  def test_on_base
    refute SecondBase.is_on_base
    SecondBase.on_base do
      assert SecondBase.is_on_base
      assert_equal SecondBase::Base.connection.class, ActiveRecord::Base.connection.class
      assert_equal [SecondBase::Railtie.fullpath('migrate')], ActiveRecord::Tasks::DatabaseTasks.migrations_paths
      assert_equal SecondBase::Railtie.fullpath, ActiveRecord::Tasks::DatabaseTasks.db_dir
    end
    refute SecondBase.is_on_base
  end

  def test_on_base_nested
    refute SecondBase.is_on_base
    SecondBase.on_base do
      assert SecondBase.is_on_base
      SecondBase.on_base do
        assert SecondBase.is_on_base
      end
      assert SecondBase.is_on_base
    end
    refute SecondBase.is_on_base
  end


end
