class Groups::RequestsController < Groups::BaseController

  before_filter :login_required # we want this
  include_controllers 'common/requests'

  def index
    @requests = Request.
      having_state(current_state).
      send(current_view, @group).
      by_updated_at.
      paginate(pagination_params)
    render :template => 'common/requests/index'
  end

  def create
    if !params[:cancel]
      req = RequestToJoinYou.create :recipient => @group, :created_by => current_user
      if req.valid?
        success(I18n.t(:invite_sent, :recipient => req.recipient.display_name))
      else
        error("Invalid request for "+req.recipient.display_name)
      end
    end
    redirect_to entity_url(@group)
  end

  protected

  def current_view
    case params[:view]
      when "incoming" then :to_group;
      when "outgoing" then :from_group;
      else :regarding_group;
    end
  end

  def requests_path(*args)
    group_request_path(@group, *args)
  end

end
