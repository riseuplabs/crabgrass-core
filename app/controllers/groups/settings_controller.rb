class Groups::SettingsController < Groups::BaseController

  before_filter :login_required

  def show
  end

  def update
    @group.update_attributes!(params[:group])
    success
    redirect_to group_settings_url(@group)
  end

end
