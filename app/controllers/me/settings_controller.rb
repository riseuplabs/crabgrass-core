class Me::SettingsController < Me::BaseController
  rescue_render update: :show

  def show
    @user.pgp_key || @user.build_pgp_key
  end

  def update
    current_user.update_attributes!(user_params)
    PgpKey.delete(@user.pgp_key.id) if @user.pgp_key and @user.pgp_key.fingerprint.blank?
    session[:language_code] = current_user.language if current_user.language
    success
    redirect_to me_settings_url
  end

  protected

  def user_params
    params.require(:user).
      merge(pgp_key_attributes: pgp_key_attributes_with_id).
      permit( :login,
              :display_name,
              :email,
              :receive_notifications,
              :language,
              :time_zone,
              pgp_key_attributes: [:key, :id] )
  end

  # In order to update existing keys
  # or to remove them by submitting an empty form
  # we need to add the id of the previous key.
  def pgp_key_attributes_with_id
    from_params = params.require(:user).fetch("pgp_key_attributes", nil)
    return from_params.merge(id: @user.pgp_key.try.id) if from_params
  end
end
