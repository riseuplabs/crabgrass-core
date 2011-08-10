class Groups::JoinRequestsController < Groups::BaseController

  def new
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

  def index
  end
  
  protected

  def authorized?
    if action?('create', 'new')
      may_create_join_request?
    end
  end

end
