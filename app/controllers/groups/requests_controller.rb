
class Groups::RequestsController < Groups::BaseController

  permissions 'requests'
  include_controllers 'common/controllers/request'

  def index
    @requests = Request.
      having_state(current_state).
      send(current_view, @group).
      by_updated_at.
      paginate(pagination_params)
    render :template => 'requests/index'
  end

  protected

  def current_view
    case params[:view]
      when "incoming" then :to_group;
      when "outgoing" then :from_group;
      else :regarding_group;
    end
  end

end
