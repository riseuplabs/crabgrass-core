#
# The master controller to handle all saving of all wikis.
#
# These actions are AJAX only, although the non-AJAX views in views/wikis/wikis are
# are used by Pages and Groups.
#

class Wikis::WikisController < Wikis::BaseController
  include Common::Tracking::Action

  skip_before_filter :login_required, only: :show
  before_filter :authorized?, only: :show

  # cancel button pressed
  before_filter :cancel, only: :update, if: :cancel?
  # no save param present - do nothing
  before_filter :noop, only: :update, if: :noop?

  track_actions :update

  guard show: :may_show_wiki?
  helper 'wikis/sections'
  layout false

  def show
    @last_seen = @wiki.last_version_before(last_visit) if last_visit
    render template: 'wikis/wikis/show' #, :locals => {:preview => params['preview']}
  end

  def print
    # no pagination for the posts - one large print view.
    if @page.try.discussion
      @posts = @page.discussion.visible_posts.includes(:user)
    end
    render layout: "printer_friendly"
  end

  #
  # this edit does not follow the REST model, since it alters the database
  # in order to lock the section.
  #
  def edit
    WikiLock.transaction do
      @wiki.lock!(@section, current_user)
    end
    render template: "wikis/wikis/edit"
  rescue Wiki::LockedError => @error_message
    render template: 'wikis/wikis/edit', locals: {mode: 'locked'}
  end

  #
  # three ways this can be called:
  # - cancel button     -> unlock section      - params[:cancel] (before_filter)
  # - save button       -> save section        - params[:save]
  # - force save button -> unlock, then save   - params[:force_save]
  #
  # Either :cancel, :save, or :force_save must be present for this action
  # to have any effect. Otherwise the noop before filter will render already.
  #
  def update
    WikiLock.transaction do
      @wiki.break_lock!(@section) if params[:force_save]
      # disable version checked if force save
      version = params[:force_save] ? nil : params[:wiki][:version]
      @wiki.update_section!(@section, current_user, version, params[:wiki][:body])
      success
    end
    render template: 'wikis/wikis/show'
  rescue Wiki::VersionExistsError, Wiki::LockedError => exc
    # could not save, but give user a choice to force save anyway
    @error_message = exc
    @wiki.body = @body = params[:wiki][:body]
    @wiki.version = @wiki.versions.last.version + 1
    @show_force_save_button = true
    render template: '/wikis/wikis/edit'
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

  def cancel
    @wiki.release_my_lock!(@section, current_user)
    render template: 'wikis/wikis/show'
  end

  def cancel?
    !!params[:cancel]
  end

  def noop
    render template: 'wikis/wikis/show'
  end

  def noop?
    !params[:save] && !params[:force_save]
  end
end
