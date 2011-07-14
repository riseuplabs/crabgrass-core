class Groups::JoinRequestController < Groups::BaseController

  #before_filter :login_required # hmm, not sure. this doesn't work
  permissions 'requests'


  def new
  end

  def create
    req = RequestToJoinYou.create! :recipient => @group, :created_by => current_user # create! ?
    if req.valid?
      success(:now, I18n.t(:invite_sent, :recipient => req.recipient.display_name))
    else
      error(:now, "Invalid request for "+req.recipient.display_name)
    end
    redirect_to :controller=> 'me/requests', :action => :index
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
