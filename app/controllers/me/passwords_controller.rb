class Me::PasswordsController < Me::BaseController
  rescue_render update: :edit

  def edit; end

  def update
    if params[:user][:password].empty?
      error :thing_required.t(thing: :password.t)
      render action: :edit
    else
      current_user.update_attributes! password_params
      success
      redirect_to edit_me_password_url
    end
  end

  protected

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
