class TaskListPageController < Page::BaseController
  before_filter :fetch_user_participation
  before_filter :setup_second_nav

  def show
    @pending = @page.tasks.pending
    @completed = @page.tasks.completed
  end

  protected

  def setup_second_nav
    @second_nav = 'tasks'
  end

  def fetch_user_participation
    @upart = @page.participation_for_user(current_user) if @page and current_user
  end

end
