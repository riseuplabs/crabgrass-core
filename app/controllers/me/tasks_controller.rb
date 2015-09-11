class Me::TasksController < Me::BaseController

  def index
    @tasks = tasks_for_view.order('updated_at DESC').limit(200)
  end

  protected

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
