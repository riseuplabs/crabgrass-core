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
    add_task
    assert_tasks_pending
    assert_task_assigned_to(user)
    complete_task
    assert_tasks_completed
    assert_tasks_pending
  end

  def test_assigning_task
    share_page_with users(:red)
    add_task
    close_task_form
    assign_task_to users(:red)
    assert_task_assigned_to users(:red)
    unassign_task_from user
    assert_no_task_assigned_to users(:blue)
  end

  def test_unassigning_task_from_last_user
    add_task
    unassign_task_from user
    assert_tasks_pending
    assert_no_task_assigned_to(user)
  end

  def add_task(options = {})
    options[:description] ||= Faker::Lorem.sentence
    options[:detail] ||= Faker::Lorem.paragraph
    open_task_form
    fill_in 'task_name', with: options[:description]
    fill_in 'task_description', with: options[:detail]
    click_button "Add new Task"
    return options
  end

  def unassign_task_from(user)
    edit_task
    within '#sort_list_pending' do
      uncheck user.login
    end
    click_on 'Save'
  end

  def assign_task_to(user)
    edit_task
    check user.login
    click_on 'Save'
  end

  def edit_task
    show_task
  end

  def show_task
    within '#sort_list_pending' do
      find('.task .toggle').click
    end
  end

  def open_task_form
    click_link 'Add new Task' unless page.has_button? 'Add new Task'
  end

  def close_task_form
    click_link 'Add new Task' if page.has_button? 'Add new Task'
  end

  def complete_task
    within '#sort_list_pending' do
      first('.check_off_16').click
    end
  end

  def assert_no_tasks
    assert_content 'No pending tasks'
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

  def assert_no_task_assigned_to(*users)
    users.each do |user|
      assert_no_selector '.people',
        text: user.display_name
    end
  end

  def assert_task_assigned_to(*users)
    assert_selector '.people', exact: true,
      text: users.map(&:display_name).join(', ')
  end
end
