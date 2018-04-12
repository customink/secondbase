require 'test_helper'

class ThirdBase::ForcedTest < ThirdBase::TestCase

  setup do
    run_db :create
    run_db :migrate
    establish_connection
  end

  def test_shared_pool
    assert_equal ThirdBase::Base.connection_pool.object_id,
                 FeedForced.connection_pool.object_id
  end

  def test_shared_connection
    assert_equal ThirdBase::Base.connection.raw_connection.object_id,
                 FeedForced.connection.raw_connection.object_id
  end

  def test_shared_new_connection_in_a_different_thread
    current_base_connection_id = ThirdBase::Base.connection.raw_connection.object_id
    new_base_connection_id, new_forced_connection_id = Thread.new {
      [ ThirdBase::Base.connection.raw_connection.object_id,
        FeedForced.connection.raw_connection.object_id ]
    }.value
    refute_equal new_base_connection_id, current_base_connection_id
    assert_equal new_base_connection_id, new_forced_connection_id
  end

  def test_shared_connected_query
    assert ThirdBase::Base.connected?
    assert FeedForced.connected?
    FeedForced.clear_all_connections!
    refute ThirdBase::Base.connected?
    refute FeedForced.connected?
  end

  def test_can_remove_connection_properly
    base_connection = ThirdBase::Base.connection
    forced_connection = FeedForced.connection
    assert base_connection.active?
    assert forced_connection.active?
    FeedForced.remove_connection
    refute base_connection.active?
    refute forced_connection.active?
  end

end
