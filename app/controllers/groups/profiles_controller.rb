class Groups::ProfilesController < Groups::BaseController

  before_filter :fetch_profile
  helper :profile

  def edit
  end

  def update
    if params[:clear_photo]
      @profile.picture.destroy
      success :profile_saved.t
      redirect_to edit_group_profile_url(@group)
    else
      @profile.save_from_params params['profile']
      if @profile.valid?
        success :profile_saved.t
        redirect_to edit_group_profile_url(@group)
      end
    end
  end

  private

  def fetch_profile
    if @group
      @profile = @group.profiles.public
    end
    true
  end

end
