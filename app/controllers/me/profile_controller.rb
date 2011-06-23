class Me::ProfileController < Me::BaseController

  before_filter :fetch_profile

  def edit
  end

  def update
    @profile.save_from_params params['profile']
    if @profile.valid?
      success :profile_saved.t
      redirect_to edit_me_profile_path
    end
  end

  protected

  def fetch_profile
    @profile = current_user.profiles.public
  end

end

