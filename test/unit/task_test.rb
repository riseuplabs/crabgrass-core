require_relative 'test_helper'

class TaskTest < ActiveSupport::TestCase

  def setup
  end

  def test_creation
    assert list = TaskList.create
    assert list.tasks.create
  end

  def test_deletion
    list = TaskList.create
    list.tasks.create
    id = list.tasks.first.id
    list.destroy
    assert_nil Task.find_by_id(id), 'deleting the list should delete the tasks'
  end

  def test_associations
    assert check_associations(TaskList)
    assert check_associations(Task)
#    assert check_associations(TaskParticipations)
  end

  def test_include_associations
    assert_nothing_raised do
      TaskList.includes(:tasks, :completed, :pending).first
      Task.includes(:task_list).first
    end
  end

  def test_completed
    list = TaskList.create
    t = list.tasks.create

    assert_equal false, t.completed?
    assert_nil t.completed_at
    t.state = 'complete'
    assert t.completed?
    assert t.completed_at
    t.state = 'pending'
    assert !t.completed?
    assert_nil t.completed_at

  end

end
