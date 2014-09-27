require 'javascript_integration_test'

class TaskListTest < JavascriptIntegrationTest

  def setup
    super
    own_page :task_list_page
    login
    click_on own_page.title
  end

  def test_initial_task
    assert_page_header
    assert_no_tasks
    add_task
    assert_tasks_pending
    assert_task_assigned_to(@user)
    complete_task
    assert_tasks_completed
  end

  def add_task(options = {})
    click_on 'add task' if page.has_selector?(:link, 'add task')
    options[:description] ||= Faker::Lorem.sentence
    options[:detail] ||= Faker::Lorem.paragraph
    fill_in 'task_name', :with => options[:description]
    fill_in 'task_description', :with => options[:detail]
    click_on "Add Task"
    return options
  end

  def complete_task
    within '#sort_list_pending' do
      find('.check_off_16').click
    end
  end

  def assert_no_tasks
    assert_content 'no pending tasks'
  end

  def assert_tasks_pending
    within '#sort_list_pending' do
      assert_selector '.task'
    end
  end

  def assert_tasks_completed
    within '#sort_list_completed' do
      assert_selector '.task'
    end
  end

  def assert_task_assigned_to(user)
    within '.task_people' do
      assert_content user.login
    end
  end
end
