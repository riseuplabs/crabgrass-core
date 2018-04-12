#
# This controller deals with membership requests.
#
# e.g. invite, expell, join.
#
# For other types of requests, see Group::RequestsController.
#

class Group::MembershipRequestsController < Group::BaseController
  include_controllers 'common/requests'

  # may_admin_group? is required by default.
  # permissions handled by model:
  guard create: :allow, update: :allow, destroy: :allow

  def index
    @requests = Request
                .membership_related
                .having_state(current_state)
                .send(current_view, @group)
                .by_updated_at
                .paginate(pagination_params)
    render template: 'common/requests/index'
  end

  #
  # RequestToRemoveUser
  # RequestToJoinYou
  # RequestToJoinYourNetwork
  #
  def create
    if type == :join
      create_join_request
    elsif type == :destroy
      create_destroy_request
    end
  end

  protected

  def type
    case params[:type]
    when 'destroy' then :destroy
    when 'join' then :join
    end
  end

  def current_view
    case params[:view]
    when 'incoming' then :to_group
    when 'outgoing' then :from_group
    else :regarding_group
    end
  end

  def request_path(*args)
    group_membership_request_path(@group, *args)
  end

  def requests_path(*args)
    group_membership_requests_path(@group, *args)
  end

  def create_join_request
    unless params[:cancel]
      @req = RequestToJoinYou.create recipient: @group, created_by: current_user
      alert_message @req
    end
    redirect_to entity_url(@group)
  end

  def create_destroy_request
    @entity = Entity.find_by_name!(params[:entity])
    if @entity.is_a? User
      @req = RequestToRemoveUser.create! user: @entity, group: @group, created_by: current_user
      membership = @group.memberships.find_by_user_id(@entity.id)
    elsif @entity.is_a? Group
      @req = RequestToRemoveGroup.create! group: @entity, network: @group, created_by: current_user
      membership = @group.federatings.find_by_group_id(@entity.id)
    else
      raise ErrorMessage
    end
    success @req
    respond_to do |format|
      format.js {render inline: "location.reload();" }
      format.html {redirect_to requests_path(@req)}
    end
  end
end
