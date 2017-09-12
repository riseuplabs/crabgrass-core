#
# The master controller to handle all saving of all wikis.
#
# These actions are AJAX only, although the non-AJAX views in views/wiki/wikis are
# are used by Pages and Groups.
#

class Wiki::WikisController < Wiki::BaseController
  include Common::Tracking::Action

  skip_before_filter :login_required, only: :show
  before_filter :authorized?, only: :show

  track_actions :update

  guard show: :may_show_wiki?
  helper 'wikis/sections'
  layout false

  def show
    @wiki.last_seen_at = last_visit if last_visit
    render template: 'wiki/wikis/show' # , :locals => {:preview => params['preview']}
  end

  def print
    # no pagination for the posts - one large print view.
    if @page.try.discussion
      @posts = @page.discussion.posts.visible.includes(:user)
    end
    render layout: 'printer_friendly'
  end

  #
  # this edit does not follow the REST model, since it alters the database
  # in order to lock the section.
  #
  def edit
    Wiki::Lock.transaction do
      @wiki.lock!(@section, current_user)
    end
    render template: 'wiki/wikis/edit'
  rescue Wiki::LockedError => @error_message
    render template: 'wiki/wikis/locked'
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
    release_lock if cancel?
    update_wiki if save?
    render template: 'wiki/wikis/show'
  rescue Wiki::VersionExistsError, Wiki::LockedError => exc
    # could not save, but give user a choice to force save anyway
    @error_message = exc
    @wiki.body = @body = params[:wiki][:body]
    @wiki.version = @wiki.versions.last.version + 1
    @show_force_save_button = true
    render template: '/wiki/wikis/edit'
  end

  protected

  # only track wiki updates on pages that have been saved
  def track_action(event = nil, event_options = {})
    super if @page && @wiki.previous_changes[:body]
  end

  def last_visit
    if @page
      @page.user_participations.where(user_id: current_user).pluck(:viewed_at)
    end
  end

  def release_lock
    @wiki.release_my_lock!(@section, current_user)
  end

  def update_wiki
    Wiki::Lock.transaction do
      @wiki.break_lock!(@section) if params[:force_save]
      # disable version checked if force save
      version = params[:force_save] ? nil : params[:wiki][:version]
      @wiki.update_section!(@section, current_user, version, params[:wiki][:body])
      success
    end
  end

  def cancel?
    !!params[:cancel]
  end

  def save?
    !cancel? && (params[:save] || params[:force_save])
  end
end
