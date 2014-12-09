class Me::SettingsController < Me::BaseController

  rescue_render update: :show

  def show
  end

  def update
    current_user.update_attributes!(user_params)
    if current_user.language
      session[:language_code] = current_user.language
    end
    success
    redirect_to me_settings_url
  end

  protected

  def user_params
    params.require(:user).permit :login, :display_name,
      :email, :receive_notifications, :language, :time_zone
  end
end
