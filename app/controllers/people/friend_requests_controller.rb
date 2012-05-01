class People::FriendRequestsController < People::BaseController

  def new
  end

  def create
    if params[:cancel]
      redirect_to entity_url(@user)
    else
      req = RequestToFriend.create! :recipient => @user, :created_by => current_user, :message => params[:message]
      if req.valid?
        success req
        redirect_to entity_url(@user)
      else
        error
        redirect_to new_person_requests_url(@user)
      end
    end
  end

  def destroy
    current_user.remove_contact!(@user)
    success
    redirect_to entity_url(@user)
  end

  protected

  def authorized?
    if action?('create', 'new')
      may_request_contact?
    elsif action?('destroy')
      current_user.friend_of?(@user)
    end
  end

end
