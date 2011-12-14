class WikiPageController < Pages::BaseController

  helper_method :current_locked_section, :desired_locked_section, :has_some_locked_section?,
                  :has_wrong_locked_section?, :has_desired_locked_section?, :show_inline_editor?

  #stylesheet 'wiki_edit'
  #javascript :wiki, :action => :edit

  helper 'wikis/base'

  #helper_method :save_or_cancel_edit_lock_wiki_error_text

  permissions 'wiki_page', 'wikis'

  include_controllers 'common/wiki'
  #before_filter :setup_wiki_rendering
  before_filter :find_last_seen, :only => :show
  #before_filter :force_save_or_cancel, :only => [:show, :print]

  #before_filter :ensure_desired_locked_section_exists, :only => [:edit, :update]
  # if we have some section locked, but we don't need it. we should drop the lock
  #before_filter :release_old_locked_section!, :only => [:edit, :update]

  #before_render :setup_title_box

  ##
  ## ACCESS: public or :view
  ##

=begin
  def show
    if @wiki.body.empty?
      # we have no body to show, edit instead
      redirect_to_edit
    elsif current_locked_section
      @editing_section = current_locked_section
    end
  end
=end

  def print
    render :layout => "printer-friendly"
  end

=begin
  # GET
  # plain - clicked edit tab, section = nil.  render edit ui with tabs and full markup
  # XHR - clicked pencil, section = 'someheading'. replace #wiki_html with inline editor
  def edit
    @editing_section = desired_locked_section
    @wiki.unlock!(desired_locked_section, current_user, :break => true) if params[:break_lock]
    acquire_desired_locked_section!

  rescue WikiLockError => exc
    # we couldn't acquire a lock. do nothing here for document edit. user will see 'break lock' button
    if show_inline_editor?
      @locker = @wiki.locker_of(@editing_section)
      @locker ||= User.new :login => 'unknown'
      error :wiki_is_locked.t(:user => @locker.display_name)
    end
  rescue ActiveRecord::StaleObjectError => exc
     # this exception is created by optimistic locking.
     # it means that wiki or wiki locks has change since we fetched it from the database
     error :locking_error.t
  ensure
    render :action => 'update_wiki_html' if show_inline_editor?
  end
=end


  # Handle the switch between Greencloth wiki a editor and Wysiwyg wiki editor
  def update_editors
    return unless @wiki.document_open_for?(current_user)
    render :json => update_editor_data(:editor => params[:editor], :wiki => params[:wiki])
  end

  ##
  ## PROTECTED
  ##
  protected

  def render_update_outcome
    if @update_completed
      @editing_section = nil
    else
      @wiki.body = params[:wiki][:body] if params[:wiki]
      @editing_section = desired_locked_section
    end

    render_or_redirect_to_updated_wiki_html
  end

  # called during BasePage::create
  def build_page_data
    Wiki.new(:user => current_user, :body => "")
  end

=begin
  ### REDIRECTS
  def redirect_to_edit
    redirect_to page_url(@page, :action => 'edit')
  end

  def redirect_to_show
    redirect_to page_url(@page, :action => 'show')
  end
=end

  ### RENDERS
  def render_or_redirect_to_updated_wiki_html
    if request.xhr?
      render :action => 'update_wiki_html'
    elsif @update_completed
      redirect_to_show
    else
      render :action => 'edit'
    end
  end

  ### FILTERS
#  def prepare_wiki_body_html
#    if current_locked_section and current_locked_section != :document
#      @wiki.body_html = body_html_with_form(current_locked_section)
#    end
#  end

  # called early in filter chain
  def fetch_data
    return true unless @page
    @wiki = @page.wiki
    @wiki_is_blank = @wiki.body.blank?
  end

  def fetch_context
    'test' ## TODO
  end

  def find_last_seen
    if @upart and !@upart.viewed? and @wiki.version > 1
      @last_seen = @wiki.first_version_since( @upart.viewed_at )
    end
  end

  def setup_options
    @options.show_tabs = true
  end

#  def setup_title_box
#    unless @wiki.nil? or @wiki.document_open_for?(current_user)
#      @title_addendum = render_to_string(:partial => 'locked_notice')
#    end
#  end


end
