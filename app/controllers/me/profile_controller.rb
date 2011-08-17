class Me::ProfileController < Me::BaseController

  before_filter :fetch_profile

  def edit
  end

  def update
    if params[:clear_photo]
      @profile.picture.destroy
      success :profile_saved.t
      redirect_to edit_me_profile_path 
    else
      @profile.save_from_params params['profile']
      if @profile.valid?
        success :profile_saved.t
        redirect_to edit_me_profile_path
      end
    end
  end

  protected

  def fetch_profile
    @profile = current_user.profiles.public
  end

end

