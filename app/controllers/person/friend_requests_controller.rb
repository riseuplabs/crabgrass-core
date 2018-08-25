class Person::FriendRequestsController < Person::BaseController
  before_action :login_required

  def new
    @request = RequestToFriend.new recipient: @user, created_by: current_user
    authorize @request
  end

  def create
    if params[:cancel]
      skip_authorization
      redirect_to entity_url(@user)
    else
      @request = RequestToFriend.new recipient: @user, created_by: current_user,
        message: params[:message]
      authorize @request
      if @request.save
        success @request
        create_notice @request
        redirect_to entity_url(@user)
      else
        error
        redirect_to person_home_url(@user)
      end
    end
  end

  def destroy
    skip_authorization
    raise_not_found unless current_user.friend_of? @user
    current_user.remove_contact!(@user)
    success
    redirect_to entity_url(@user)
  end

  private

  def create_notice(request_obj)
    Notice::RequestNotice.create! request_obj
  end
end
