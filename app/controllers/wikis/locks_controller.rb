class Wikis::LocksController < Wikis::BaseController

  #
  # triggered when the user hits the 'cancel' or 'break lock' button
  # when given the wiki locked error
  #
  def update
    if params[:cancel]
      render :template => 'wikis/wikis/show'
    elsif params[:break_lock]
      @wiki.break_lock!(@section)
      @wiki.lock!(@section, current_user)
      render :template => 'wikis/wikis/edit'
    end
  end

  #
  # This is an ajax request that releases the lock when leaving a wiki.
  # We don't expect anything in return as this is called from
  # onbeforeunload.
  #
  def destroy
    @wiki.release_my_lock!(@section, current_user)
    render :text => nil
  end

end
