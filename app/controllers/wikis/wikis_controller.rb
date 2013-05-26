#
# The master controller to handle all saving of all wikis.
#
# These actions are AJAX only, although the non-AJAX views in views/wikis/wikis are
# are used by Pages and Groups.
#

class Wikis::WikisController < Wikis::BaseController

  skip_before_filter :login_required, :only => :show
  before_filter :authorized?, :only => :show

  guard :show => :may_show_wiki?
  helper 'wikis/sections'
  layout false

  def show
    render :template => 'wikis/wikis/show' #, :locals => {:preview => params['preview']}
  end

  def print
    @posts = @page.posts if @page
    render :layout => "printer_friendly"
  end

  #
  # this edit does not follow the REST model, since it alters the database
  # in order to lock the section.
  #
  def edit
    WikiLock.transaction do
      @wiki.lock!(@section, current_user)
    end
    render :template => "wikis/wikis/edit"
  rescue Wiki::LockedError => @error_message
    render :template => 'wikis/wikis/edit', :locals => {:mode => 'locked'}
  end

  #
  # three ways this can be called:
  # - cancel button     -> unlock section      - params[:cancel]
  # - save button       -> save section        - params[:save]
  # - force save button -> unlock, then save   - params[:force_save]
  #
  # Either :cancel, :save, or :force_save must be present for this action
  # to have any effect.
  #
  def update
    WikiLock.transaction do
      if params[:cancel]
        @wiki.release_my_lock!(@section, current_user)
      elsif params[:force_save]
        @wiki.break_lock!(@section)
      end
      if params[:save] || params[:force_save]
        version = params[:save] ? params[:wiki][:version] : nil # disable version checked if force save
        @wiki.update_section!(@section, current_user, version, params[:wiki][:body])
        success
      end
    end
    render :template => 'wikis/wikis/show'
  rescue Wiki::VersionExistsError, Wiki::LockedError => exc
    # could not save, but give user a choice to force save anyway
    @error_message = exc
    @wiki.body = @body = params[:wiki][:body]
    @wiki.version = @wiki.versions.last.version + 1
    @show_force_save_button = true
    render :template => '/wikis/wikis/edit'
  end

end
