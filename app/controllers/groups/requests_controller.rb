#
# controller for:
# 
# (1) listing all requests for this group, regardless of type.
# (2) creating non-membership requests.
#
#
class Groups::RequestsController < Groups::BaseController

  include_controllers 'common/requests'

  guard :index => :may_list_group_requests?,
        :show => :may_list_group_requests?,
        # permissions handled by model:
        :create => :allow, :update => :allow, :destroy => :allow

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
    case request_type
      when :destroy_group then create_destroy_group_request
      when :create_council then create_create_council_request
    end
  end

  protected

  def request_type
    if params[:type] == 'destroy_group'
      :destroy_group
    elsif params[:type] == 'create_council'
      :create_council
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

  def create_destroy_group_request
    req = RequestToDestroyOurGroup.create! :recipient => @group, :requestable => @group, :created_by => current_user
    success
    redirect_to request_path(req)
  end

  def create_create_council_request
    # not supported yet.
  end
  
end
