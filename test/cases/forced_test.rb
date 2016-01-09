require 'test_helper'

class ForcedTest < SecondBase::TestCase

  setup do
    run_db :create
    run_db :migrate
    establish_connection
  end

  def test_shared_pool
    assert_equal SecondBase::Base.connection_pool.object_id,
                 CommentForced.connection_pool.object_id
  end

  def test_shared_connection
    assert_equal SecondBase::Base.connection.raw_connection.object_id,
                 CommentForced.connection.raw_connection.object_id
  end

  def test_shared_new_connection_in_a_different_thread
    current_base_connection_id = SecondBase::Base.connection.raw_connection.object_id
    new_base_connection_id, new_forced_connection_id = Thread.new {
      [ SecondBase::Base.connection.raw_connection.object_id,
        CommentForced.connection.raw_connection.object_id ]
    }.value
    refute_equal new_base_connection_id, current_base_connection_id
    assert_equal new_base_connection_id, new_forced_connection_id
  end

  def test_shared_connected_query
    assert SecondBase::Base.connected?
    assert CommentForced.connected?
    CommentForced.clear_all_connections!
    refute SecondBase::Base.connected?
    refute CommentForced.connected?
  end

  def test_can_remove_connection_properly
    base_connection = SecondBase::Base.connection
    forced_connection = CommentForced.connection
    assert base_connection.active?
    assert forced_connection.active?
    CommentForced.remove_connection
    refute base_connection.active?
    refute forced_connection.active?
  end

end
