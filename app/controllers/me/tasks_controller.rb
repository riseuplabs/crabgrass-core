class Me::TasksController < Me::BaseController

  def index
    @pages = pages_with_tasks
      .not_deleted
      .order('pages.updated_at DESC')
      .limit(20)
  end

  protected

  def pages_with_tasks
    TaskListPage.with_tasks tasks_for_view
  end

  def tasks_for_view
    current_user.tasks.send(view)
  end

  def view
    completed? ? :completed : :pending
  end

  def completed?
    params[:view] == 'completed'
  end

end
