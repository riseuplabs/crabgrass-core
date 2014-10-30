require 'javascript_integration_test'

class TaskListTest < JavascriptIntegrationTest
  fixtures :users

  def setup
    super
    @user = users(:blue)
    own_page :task_list_page
    login
    click_on own_page.title
  end

  def test_initial_task
    assert_page_header
    assert_no_tasks
    add_task
    assert_tasks_pending
    assert_task_assigned_to(user)
    complete_task
    assert_tasks_completed
  end

  def test_assigning_task
    share_page_with users(:red)
    add_task
    click_on 'Done'
    assign_task_to users(:red)
    unassign_task_from user
    assert_task_not_assigned_to users(:blue)
    assert_task_assigned_to users(:red)
  end

  def add_task(options = {})
    click_on 'add task' if page.has_selector?(:link, 'add task')
    options[:description] ||= Faker::Lorem.sentence
    options[:detail] ||= Faker::Lorem.paragraph
    fill_in 'task_name', with: options[:description]
    fill_in 'task_description', with: options[:detail]
    click_on "Add Task"
    return options
  end

  def unassign_task_from(user)
    edit_task
    uncheck user.display_name
    click_on 'Save'
  end

  def assign_task_to(user)
    edit_task
    check user.display_name
    click_on 'Save'
  end

  def edit_task
    show_task
    within '#sort_list_pending' do
      click_on 'Edit'
    end
  end

  def show_task
    within '#sort_list_pending' do
      find('.task').click
    end
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

  def assert_task_not_assigned_to(*users)
    users.each do |user|
      assert_no_selector '.task_people',
        text: user.login
    end
  end

  def assert_task_assigned_to(*users)
    assert_selector '.task_people', exact: true,
      text: users.map(&:login).join(', ')
  end
end
