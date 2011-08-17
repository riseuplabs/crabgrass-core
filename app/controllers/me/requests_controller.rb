class Me::RequestsController < Me::BaseController

  include_controllers 'common/requests'
  before_filter :check_permissions!, :only => [:destroy, :update]

  def index
    @requests = Request.
      having_state(current_state).
      send(current_view, current_user).
      by_updated_at.
      paginate(pagination_params)
    render :template => 'common/requests/index'
  end

  protected

  def current_view
    case params[:view]
      when "incoming" then :to_user;
      when "outgoing" then :created_by;
      else :to_or_created_by_user;
    end
  end

  def request_path(*args)
    me_request_path(*args)
  end


end
