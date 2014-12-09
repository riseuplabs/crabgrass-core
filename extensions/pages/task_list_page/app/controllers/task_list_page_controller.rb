class TaskListPageController < Pages::BaseController
  before_filter :fetch_task_list, :fetch_user_participation

  def show
  end

  protected

  def initialize(options={})
    super(options)
    @second_nav = 'tasks'
  end

  def update_participations
    users_pending = {}
    page_resolved = true

    # build a hash of the completed status for each user
    @list.tasks.each do |task|
      task.users.each do |user|
        users_pending[user] ||= (not task.completed?)
      end
      page_resolved &&= task.completed?
    end

    # make the page resolved iff all the tasks are completed
    @page.update_attribute(:resolved, page_resolved) if @page.resolved? != page_resolved

    # update each user's resolved status
    users_pending.each do |user,pending|
      user.resolved(@page, (not pending))
    end

    # current_user.updated(@page) <-- if we want the page to become unread on each update
    @page.save # instead of current_user.updated
    return true
  end

  def fetch_task_list
    return true unless @page
    unless @page.data
      @page.data = TaskList.create
      current_user.updated @page
    end
    @list = @page.data
  end

  def fetch_user_participation
    @upart = @page.participation_for_user(current_user) if @page and current_user
  end

end
