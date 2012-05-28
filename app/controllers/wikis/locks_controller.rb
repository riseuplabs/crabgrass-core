class Wikis::LocksController < Wikis::BaseController

  # the model takes care of the permissions
  skip_before_filter :login_required

  # This is an ajax request that releases the lock when leaving a wiki.
  # We don't expect anything in return as this is called from
  # onbeforeunload.
  # Wiki#unlock! handles permissions for us aswell.
  def destroy
    @wiki.unlock!(params[:section] || :document, current_user)
    render :text => nil
  rescue Wiki::SectionLockedError
    render :text => 'permission denied'
  end

end
