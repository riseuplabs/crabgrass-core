class Me::SettingsController < Me::BaseController

  rescue_render update: :show

  def show
  end

  def update
    current_user.update_attributes!(params[:user])
    if current_user.language
      session[:language_code] = current_user.language
    end
    success
    redirect_to me_settings_url
  end

end
