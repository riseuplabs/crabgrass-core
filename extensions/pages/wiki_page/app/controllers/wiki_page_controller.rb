class WikiPageController < Pages::BaseController

  guard print: :may_show_page?
  helper 'wikis/base', 'wikis/sections'
  permission_helper 'wikis'

  before_filter :find_last_seen, only: :show

  def show
    if default_to_edit?
      params[:action] = 'edit'
      render template: '/wikis/wikis/edit'
    else
      render template: '/wikis/wikis/show'
    end
  end

  def print
    if @page.try.discussion
      @posts = @page.try.discussion.visible_posts.includes(:user)
    end
    render template: 'wikis/wikis/print', layout: 'printer_friendly'
  end

  protected

  # called during BasePage::create
  def build_page_data
    Wiki.new(user: current_user, body: "")
  end

  def fetch_data
    return true unless @page
    @wiki = @page.wiki
  end

  def fetch_context
    'test' ## TODO
  end

  def find_last_seen
    if @upart and !@upart.viewed? and @wiki.version > 1
      @last_seen = @wiki.last_version_before( @upart.viewed_at )
    end
  end

  def setup_options
    @options.show_tabs = true
  end

  def default_to_edit?
    @wiki.body.blank? && may_edit_page?
  end

end
