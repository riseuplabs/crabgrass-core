class Me::ProfileController < Me::BaseController
  before_action :fetch_profile
  helper :profile

  def edit; end

  def update
    if params[:clear_photo]
      @profile.picture.destroy
    else
      @profile.save_from_params profile_params
    end
    success :profile_saved.t
    redirect_to edit_me_profile_path
  end

  protected

  def fetch_profile
    @profile = current_user.profiles.public
  end

  def profile_params
    params[:profile].permit :place, :organization, :role, :summary,
                            picture: [:upload]
  end
end
