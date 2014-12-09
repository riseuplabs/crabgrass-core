class Me::DestroysController < Me::BaseController

  rescue_render update: :show

  def show
  end

  def update
    @user = current_user.ghostify!
    @user.retire!
    if params[:scrub_name]
      @user.anonymize!
    end
    if params[:scrub_comments]
      @user.destroy_comments!
    end
    logout!
    success :account_successfully_removed.t
    redirect_to '/'
  end

end
