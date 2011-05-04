class Groups::ProfileController < Groups::BaseController

  before_filter :fetch_profile, :login_required

  def show 
  end

  def update
    @profile.update_attributes!(params[:profile])
    success
    redirect_to group_profile_url(@group)
  end

  private

  def fetch_profile
    if @group
      @profile = @group.profiles.public
    end
    true
  end

end
