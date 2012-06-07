class WikiPageController < Pages::BaseController

  guard :print => :may_show_page?
  helper 'wikis/base', 'wikis/sections'
  permission_helper 'wikis'

  before_filter :find_last_seen, :only => :show
  before_render :setup_title_box

  stylesheet 'wiki_edit'
  ##
  ## ACCESS: public or :view
  ##

  def show
    render :template => '/common/wiki/show'
  end

  ##
  ## PROTECTED
  ##
  protected

  # called during BasePage::create
  def build_page_data
    Wiki.new(:user => current_user, :body => "")
  end

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
