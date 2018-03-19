require 'test_helper'

class ThirdBase::OnBaseTest < ThirdBase::TestCase

  setup do
    run_db :create
    run_db :migrate
    establish_connection
  end

  def test_on_base
    refute ThirdBase.is_on_base
    ThirdBase.on_base do
      assert ThirdBase.is_on_base
      assert_equal ThirdBase::Base.connection.class, ActiveRecord::Base.connection.class
      assert_equal [ThirdBase::Railtie.fullpath('migrate')], ActiveRecord::Tasks::DatabaseTasks.migrations_paths
      assert_equal ThirdBase::Railtie.fullpath, ActiveRecord::Tasks::DatabaseTasks.db_dir
    end
    refute ThirdBase.is_on_base
  end

  def test_on_base_nested
    refute ThirdBase.is_on_base
    ThirdBase.on_base do
      assert ThirdBase.is_on_base
      ThirdBase.on_base do
        assert ThirdBase.is_on_base
      end
      assert ThirdBase.is_on_base
    end
    refute ThirdBase.is_on_base
  end


end
