class Groups::SettingsController < Groups::BaseController

  def show
  end

  def update
    @group.update_attributes!(params[:group])
    success
    redirect_to group_settings_url(@group)
  end

  protected

  def group_type
    @group.class.name.downcase.to_sym
  end
  helper_method :group_type

end
