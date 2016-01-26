class Me::DestroysController < Me::BaseController

  rescue_render update: :show

  def show
  end

  def update
    # these will be cleared after retire!
    @user.retire! params.slice(:scrub_name, :scrub_comments)
    notify @user.friends
    success :account_successfully_removed.t
    logout!
    redirect_to '/'
  end

  protected

  # fetch user as a User::Ghost
  def fetch_user
    if action?(:update)
      @user = current_user.ghostify!
    else
      super
    end
  end

  def notify(users_to_notify)
    # current_user still has a name.
    notification = Notification.new(:user_destroyed, username: current_user.name)
    notification.create_notices_for(users_to_notify)
  end

end
