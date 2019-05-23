module TaskListPageHelper
  # creates a link that expands to display the task details.
  # options must include :show or :toggle
  def task_link_to_details(task, *options)
    name = h(task.name)
    id = dom_id(task, 'details')
    if options.include?(:show)
      link_to_function(
        name,
        show(id) + edit_task_details_function(task),
        class: 'toggle'
      )
    elsif options.include?(:toggle)
      link_to_function(
        name,
        toggle(id),
        class: 'toggle'
      )
    end
  end

  def task_modification_flag(task)
    if task.created_at and last_visit < task.created_at
      content_tag(:span, :new.t, class: 'label label-success')
    elsif task.updated_at and last_visit < task.updated_at
      content_tag(:span, :modified.t, class: 'label label-primary')
    end
  end

  # makes links of the people assigned to a task like: "joe, janet, jezabel: "
  def task_link_to_people(task)
    links = task.users.collect do |user|
      link_to_user(user, action: 'tasks', class: 'hov')
    end.join(', ').html_safe
  end

  # a button to delete the task
  def delete_task_details_button(task)
    function = remote_function(
      url: task_url(task, page_id: task.page),
      method: 'delete',
      loading: show_spinner(task),
      complete: hide(task)
    )
    button_to_function :delete.t, function, class: 'btn btn-danger'
  end

  def edit_task_details_function(task)
    remote_function(
      url: edit_task_url(task, page_id: task.page),
      loading: show_spinner(task),
      method: :get
    )
  end

  ##
  ## edit task form
  ##

  def possible_users(_task, page)
    return @possible_users if @possible_users
    @possible_users = []
    @possible_users += page.users.with_access if page.users.with_access.any?
    page.groups.each do |group|
      @possible_users += group.users
    end
    @possible_users.uniq!
    @possible_users
  end

  def options_for_task_edit_form(task)
    [{
      loading: show_spinner(task),
      method: :put,
      remote: :true,
      html: {}
    }]
  end

  def checkboxes_for_assign_people_to_task(task, selected = nil, page = nil)
    page ||= task.page
    render partial: 'tasks/assigned_checkbox',
           collection: possible_users(task, page),
           as: :user,
           locals: { selected: selected }
  end

  def close_task_edit_button(task)
    button_to_function :cancel.t, hide(task, 'details'), class: 'btn btn-default'
  end

  def delete_task_edit_button(task)
    delete_task_details_button(task)
  end

  def save_task_edit_button(_task)
    submit_tag :save_button.t, class: 'btn btn-primary'
  end

end
