class Me::RequestsController < Me::BaseController

  permissions 'requests'
  include_controllers 'common/requests'

  def index
    @requests = Request.
      having_state(current_state).
      send(current_view, current_user).
      by_updated_at.
      paginate(pagination_params)
    render :template => 'common/requests/index'
  end

  protected

  # unlike other me controllers, we actually want to check
  # permissions for requests
  def authorized?
    true # check_permissions!
  end

  def current_view
    case params[:view]
      when "incoming" then :to_user;
      when "outgoing" then :created_by;
      else :to_or_created_by_user;
    end
  end

end
