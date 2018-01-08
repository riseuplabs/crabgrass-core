class Me::SettingsController < Me::BaseController
  rescue_render update: :show

  def show
    @user.pgp_key || @user.build_pgp_key
  end

  def update
    params = user_params.to_h
    if @user.pgp_key and params["pgp_key_attributes"]
      params["pgp_key_attributes"]["id"] = @user.pgp_key.id
      params_with_id = ActionController::Parameters.new(params)
      params_with_id.permit!
      current_user.update_attributes!(params_with_id)
    else
      current_user.update_attributes!(user_params)
    end
    PgpKey.delete(@user.pgp_key.id) if @user.pgp_key and @user.pgp_key.fingerprint.blank?
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
