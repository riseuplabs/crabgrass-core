#
# controller for:
#
# (1) listing all requests for this group, regardless of type.
# (2) creating non-membership requests.
#
#
class Groups::RequestsController < Groups::BaseController

  include_controllers 'common/requests'

  # guard defaults to may_admin_group?
  # permissions handled by model:
  guard :create => :allow, :update => :allow, :destroy => :allow

  rescue_render :create => :index

  def index
    @requests = Request.
      having_state(current_state).
      send(current_view, @group).
      by_updated_at.
      paginate(pagination_params)
    render :template => 'common/requests/index'
  end

  #
  # RequestToDestroyOurGroup
  # RequestToCreateCouncil
  #
  def create
    req = requested_class.create! :recipient => @group,
      :requestable => @group,
      :created_by => current_user
    success req
    redirect_to request_path(req)
  end

  protected

  def requested_class
    if params[:type] == 'destroy_group'
      RequestToDestroyOurGroup
    elsif params[:type] == 'create_council'
      RequestToCreateCouncil
    end
  end

  def current_view
    case params[:view]
      when "incoming" then :to_group
      when "outgoing" then :from_group
      else :regarding_group
    end
  end

  def request_path(*args)
    group_request_path(@group, *args)
  end

  def requests_path(*args)
    group_requests_path(@group, *args)
  end

end
