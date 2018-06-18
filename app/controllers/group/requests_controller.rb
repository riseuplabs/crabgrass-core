#
# controller for:
#
# (1) listing all requests for this group, regardless of type.
# (2) creating non-membership requests.
#
#
class Group::RequestsController < Group::BaseController
  include_controllers 'common/requests'

  rescue_render create: :index

  def index
    authorize @group, :admin?
    @requests = Request
                .having_state(current_state)
                .send(current_view, @group)
                .by_updated_at
                .paginate(pagination_params)
    render template: 'common/requests/index'
  end

  #
  # RequestToDestroyOurGroup
  # RequestToCreateCouncil
  #
  def create
    @req = requested_class.create! recipient: @group,
                                   requestable: @group,
                                   created_by: current_user
    authorize @req
    success @req
    redirect_to request_path(@req)
  end

  protected

  REQUEST_TYPES = {
    destroy_group: 'RequestToDestroyOurGroup',
    create_council: 'RequestToCreateCouncil'
  }.with_indifferent_access

  def requested_class
    REQUEST_TYPES[params[:type]].try.constantize
  end

  def current_view
    case params[:view]
    when 'incoming' then :to_group
    when 'outgoing' then :from_group
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
