three methods of reporting errors:

method 1 -- the normal way

  def update
    if current_user.update_attributes(params[:user])
      flash_message :success
      redirect_to me_settings_url
    else
      flash_message :object => current_user
      render :action => "edit"
    end
  end

method 2 -- manual call to render_error

  def update
    current_user.update_attributes!(params[:user])
    flash_message :success
    redirect_to me_settings_url
  rescue Exception => exc
    render_error exc, :action => "edit"
  end

method 3 -- automatically

  def update
    current_user.update_attributes!(params[:user])
    flash_message :success
    redirect_to me_settings_url
  end

method 4 -- semi-automatically
  
  for when an error in 'update' should render the action 'show' instead of 'edit'

  rescue_render :update => :show

  def update
    current_user.update_attributes!(params[:user])
    flash_message :success
    redirect_to me_settings_url
  end


