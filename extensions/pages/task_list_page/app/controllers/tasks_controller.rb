class TasksController < Page::BaseController
  before_filter :fetch_task, only: %i[edit update destroy]
  before_filter :setup_second_nav
  after_filter :update_participations, only: %i[create update destroy]

  def create
    @task = @page.tasks.new task_params.merge created_by: current_user
    @task.name = 'untitled' if @task.name.blank?
    current_user.updated(@page) if @task.save
  end

  # ajax only, returns nothing
  # for this to work, there must be a <ul id='sort_list_xxx'> element
  # and it must be declared sortable like this:
  # <%= sortable_element 'sort_list_xxx', .... %>
  def sort
    ids = sort_params
    @page.tasks.each do |task|
      i = ids.index(task.id.to_s)
      task.without_timestamps do
        task.update_attribute('position', i + 1) if i
      end
    end
    render nothing: true
  end

  def edit; end

  def update
    state = params[:task].try.delete(:state)
    if state.present?
      @task.state = state
      @task.move_to_bottom
    else
      @task.update_attributes task_params
    end
    current_user.updated(@page)
  end

  def destroy
    @task.remove_from_list
    @task.destroy
    current_user.updated(@page)
    render nothing: true
  end

  protected

  def setup_second_nav
    @second_nav = 'tasks'
  end

  def fetch_data
    authorize @page, :edit?
  end

  def fetch_task
    @task = @page.tasks.find params[:id]
  end

  def task_params
    params.require(:task)
          .reverse_merge(user_ids: [])
          .permit(:name, :description, user_ids: [])
  end

  def sort_params
    # we only sort one list at a time.
    list_params.values.first.reject { |i| i.to_i == 0 } # only allow integers
  end

  def list_params
    params.permit sort_list_pending: [], sort_list_completed: []
  end

  def update_participations
    users_pending = {}
    page_resolved = true

    # build a hash of the completed status for each user
    @page.tasks.each do |task|
      task.users.each do |user|
        users_pending[user] ||= !task.completed?
      end
      page_resolved &&= task.completed?
    end

    # make the page resolved iff all the tasks are completed
    @page.update_attribute(:resolved, page_resolved) if @page.resolved? != page_resolved

    # update each user's resolved status
    users_pending.each do |user, pending|
      user.resolved(@page, !pending)
    end

    # current_user.updated(@page) <-- if we want the page to become unread on each update
    @page.save # instead of current_user.updated
    true
  end
end
