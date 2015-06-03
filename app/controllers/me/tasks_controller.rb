class Me::TasksController < Me::BaseController

  def index
    if completed?
      @tasks = current_user.tasks.completed.order('updated_at DESC')
    else
      @tasks = current_user.tasks.pending.order('updated_at DESC').limit(200)
    end
  end

  protected

  def completed?
    params[:view] == 'completed'
  end

end
