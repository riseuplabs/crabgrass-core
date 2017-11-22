class Me::SettingsController < Me::BaseController
  rescue_render update: :show

  def show
    @user.pgp_key ||= PgpKey.new
  end

  def update
    current_user.update_attributes!(user_params)
    session[:language_code] = current_user.language if current_user.language
    success
    redirect_to me_settings_url
  end

  protected

  def user_params
    params.require(:user).permit :login, :display_name,
                                 :email, :receive_notifications, :language, :time_zone, pgp_key_attributes: [:key]
  end
end
