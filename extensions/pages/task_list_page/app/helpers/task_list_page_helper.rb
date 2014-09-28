module TaskListPageHelper

  ##
  ## show tasks
  ##

  def list_for_task(list, options)
    case options[:status]
    when 'pending'
      tasks = list.tasks.select { |t| t.completed == false }
    when 'completed'
      tasks = list.tasks.select { |t| t.completed == true }
    else
      list.tasks
    end
    tasks.any? ? tasks.sort_by { |t| [(t.completed? ? 1 : 0), t.position]} : []
  end

  def options_for_task_list
    options = {}
    options[:user]        = @user ? @user : nil
    options[:all_users]   = @user ? false : true
    options[:status]      = @show_status ? @show_status : 'pending'
    options[:all_states]  = @show_status == 'both'
    options[:completed]   = @show_status == 'completed'
    options
  end

  ##
  ## show task
  ##

  # creates a checkbox tag for a task
  def task_checkbox(task)
    disabled = !current_user.may?(:edit, task.task_list.page)
    if (disabled)
      content_tag :li, task.name, class: 'icon checkoff'
    else
      next_state = task.completed? ? 'pending' : 'complete'
      url =  page_xurl(task.task_list.page, action: 'mark_task_'+next_state, id: task.id)
      name = "#{task.id}_task"
      spinbox_tag name, url, checked: task.completed?, tag: :span
    end
  end

  # creates a link that expands to display the task details.
  def task_link_to_details(task)
    id = dom_id(task, 'details')
    name = task.name
    if logged_in?
      if task.created_at and logged_in_since < task.created_at
        name += content_tag(:b," (new)")
      elsif task.updated_at and logged_in_since < task.updated_at
        name += content_tag(:b," (modified)")
      end
    end
    link_to_function(name, "$('%s').toggle()" % id)
  end

  # makes links of the people assigned to a task like: "joe, janet, jezabel: "
  def task_link_to_people(task)
    links = task.users.collect{|user|
      link_to_user(user, action: 'tasks', class: 'hov')
    }.join(', ').html_safe
  end

  # a button to hide the task detail
  def close_task_details_button(task)
    button_to_function "Hide", hide(task, 'details')
  end

  # a button to delete the task
  def delete_task_details_button(task)
    function = remote_function(
      url: page_xurl(task.task_list.page, action: 'destroy_task', id: task.id),
      loading: show_spinner(task),
      complete: hide(task)
    )
    button_to_function "Delete", function
  end

  # a button to replace the task detail with a tast edit form.
  def edit_task_details_button(task)
    function = remote_function(
      url: page_xurl(task.task_list.page, action: 'edit_task', id: task.id),
      loading: show_spinner(task)
    )
    button_to_function "Edit", function
  end

  def no_pending_tasks(visible)
    content_tag(:li, 'no pending tasks', id: 'no_pending_tasks', style: (visible ? nil : 'display:none'))
  end

  def no_completed_tasks(visible)
    content_tag(:li, 'no completed tasks', id: 'no_completed_tasks', style: (visible ? nil : 'display:none'))
  end

  ##
  ## edit task form
  ##

  def possible_users(task, page)
    return @possible_users if @possible_users
    @possible_users = []
    if page.users.with_access.any?
      @possible_users += page.users.with_access
    end
    page.groups.each do |group|
      @possible_users += group.users
    end
    @possible_users.uniq!
    return @possible_users
  end

  def options_for_task_edit_form(task)
    [{
      url: page_xurl(task.task_list.page, action: 'update_task', id: task.id),
      loading: show_spinner(task),
      html: {}
    }]
  end

  def checkboxes_for_assign_people_to_task(task, selected=nil, page = nil)
    page ||= task.task_list.page
    render partial: 'assigned_checkbox',
      collection: possible_users(task, page),
      as: :user,
      locals: {selected: selected}
  end

  def close_task_edit_button(task)
    button_to_function "Cancel", hide(task, 'details')
  end

  def delete_task_edit_button(task)
    delete_task_details_button(task)
  end

  def save_task_edit_button(task)
    submit_tag 'Save'
  end

  ###
  ### new task form
  ###

  def options_for_new_task_form(page)
    [{
      url: page_xurl(page, action: 'create_task'),
      html: {action: page_url(page, action: 'create_task'), id: 'new-task-form'}, # non-ajax fallback
      loading: show_spinner('new-task'),
      complete: hide_spinner('new-task'),
      success: reset_form('new-task-form')
    }]
  end

end

