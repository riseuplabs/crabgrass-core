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
    disabled = !current_user.may?(:edit, task.page)
    if true
      content_tag(:label, class: 'checkbox-inline') do
        content_tag(:input, '',type: 'checkbox', disabled: 'disabled') +
        h(task.name)
      end
    else
      next_state = task.completed? ? 'pending' : 'complete'
      name = "#{task.id}_task"
      spinbox_tag name, task_url(task, page_id: task.page),
        checked: task.completed?,
        tag: :span,
        method: :put,
        with: "'task[state]=#{next_state}'"
    end
  end

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
    links = task.users.collect{|user|
      link_to_user(user, action: 'tasks', class: 'hov')
    }.join(', ').html_safe
  end

  # a button to hide the task detail
  def close_task_details_button(task)
    button_to_function :hide.t, hide(task, 'details')
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

  # a button to replace the task detail with a tast edit form.
  #def edit_task_details_button(task)
  #  button_to_function :edit.t,
  #    edit_task_details_function(task),
  #    class: 'btn btn-primary'
  #end

  def edit_task_details_function(task)
    remote_function(
      url: edit_task_url(task, page_id: task.page),
      loading: show_spinner(task),
      method: :get
    )
  end

  #def no_pending_tasks(visible)
  #  empty_list_item :no_pending_tasks, hidden: !visible
  #end

  #def no_completed_tasks(visible)
  #  empty_list_item :no_completed_tasks, hidden: !visible
  #end

  #def empty_list_item(message, options = {})
  #  content_tag :li, message.t, id: message,
  #    style: (options[:hidden] && 'display:none')
  #end

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
      url: task_url(task, page_id: task.page),
      loading: show_spinner(task),
      method: :put,
      html: {}
    }]
  end

  def checkboxes_for_assign_people_to_task(task, selected=nil, page = nil)
    page ||= task.page
    render partial: 'tasks/assigned_checkbox',
      collection: possible_users(task, page),
      as: :user,
      locals: {selected: selected}
  end

  def close_task_edit_button(task)
    button_to_function :cancel.t, hide(task, 'details'), class: 'btn btn-default'
  end

  def delete_task_edit_button(task)
    delete_task_details_button(task)
  end

  def save_task_edit_button(task)
    submit_tag :save_button.t, class: 'btn btn-primary'
  end

  ###
  ### new task form
  ###

  def options_for_new_task_form(page)
    [{
      url: tasks_url(page_id: page),
      html: {id: 'new-task-form'},
      loading: show_spinner('new-task'),
      complete: hide_spinner('new-task'),
      success: reset_form('new-task-form')
    }]
  end

end

