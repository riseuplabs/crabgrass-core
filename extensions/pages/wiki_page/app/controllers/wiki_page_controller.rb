class WikiPageController < Pages::BaseController


  helper 'wikis/base'


  permissions 'wiki_page', 'wikis'

  include_controllers 'common/wiki'
  #before_filter :setup_wiki_rendering
  before_filter :find_last_seen, :only => :show
  #before_filter :force_save_or_cancel, :only => [:show, :print]

  before_render :setup_title_box

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
    render :template => 'common/wiki/show',
      :layout => "printer_friendly"
  end


  ##
  ## PROTECTED
  ##
  protected

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

  def setup_title_box
    unless @wiki.nil? or @wiki.document_open_for?(current_user)
      locker = @wiki.locker_of(:document)
      @title_addendum = :wiki_is_locked.t(:user => locker.display_name)
    end
  end


end
