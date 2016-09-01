class Person::FriendRequestsController < Person::BaseController

  before_filter :login_required

  guard create: :may_request_contact?,
    new: :may_request_contact?,
    destroy: :may_remove_contact?

  def new
  end

  def create
    if params[:cancel]
      redirect_to entity_url(@user)
    else
      req = RequestToFriend.create! recipient: @user, created_by: current_user,
        message: params[:message]
      if req.valid?
        success req
        create_notice req
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

  private

  def create_notice(request_obj)
    RequestNotice.create! request_obj
  end

end
