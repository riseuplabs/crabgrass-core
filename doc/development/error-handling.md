Error Handling
==============

There's two kinds of exceptions - the ones that are part of a normal workflow
and those that you would not expect in the first place. Someone trying to
access a private page without being logged in is part of the former whereas
a full disk is part of the latter.

Try to catch the first kind of exceptions in the controller where they might
occur and handle them there. We used to rely on the ErrorApp middleware but
that does not work properly with cookies and thus sessions and should only
be used as a fallback for the second kind of exceptions.

There are four methods of reporting errors:

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


