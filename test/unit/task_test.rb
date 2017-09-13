require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  def test_creation
    assert Task.create
  end

  def test_associations
    assert check_associations(Task)
  end

  def test_setting_state
    t = Task.create

    assert_equal false, t.completed?
    assert_nil t.completed_at
    t.state = 'complete'
    assert t.completed?
    assert t.completed_at
    t.state = 'pending'
    assert !t.completed?
    assert_nil t.completed_at
  end

  def test_unassigning_from_last_user
    task = Task.create
    task.user_ids = [users(:blue).id]
    task.save
    task.user_ids = []
    task.save
    assert_equal [], task.user_ids
  end
end
