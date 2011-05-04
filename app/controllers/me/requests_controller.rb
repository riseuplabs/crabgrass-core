class Me::RequestsController < Me::BaseController

  permissions 'requests'
  include_controllers 'common/controllers/request'

  def index
    @requests = Request.
      having_state(current_state).
      send(current_view, current_user).
      by_updated_at.
      paginate(pagination_params)
    render :template => 'requests/index'
  end

  protected

  # unlike other me controllers, we actually want to check
  # permissions for requests
  def authorized?
    true # check_permissions!
  end

end
