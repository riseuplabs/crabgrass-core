class Me::SettingsController < Me::BaseController

  rescue_render :update => :show

  def show
  end

  def update
    current_user.update_attributes!(params[:user])
    success
    redirect_to me_settings_url
  end

end
