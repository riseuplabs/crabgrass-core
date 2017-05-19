class WikiPageController < Page::BaseController

  helper 'wikis/base', 'wikis/sections'
  permission_helper 'wikis'

  before_filter :find_last_seen, only: :show

  def show
    if default_to_edit?
      params[:action] = 'edit'
      render template: '/wiki/wikis/edit'
    else
      render template: '/wiki/wikis/show'
    end
  end

  def print
    if @page.try.discussion
      @posts = @page.try.discussion.posts.visible.includes(:user)
    end
    render template: 'wiki/wikis/print', layout: 'printer_friendly'
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

  def find_last_seen
    if @upart and !@upart.viewed? and @wiki.version > 1
      @wiki.last_seen_at = @upart.viewed_at
    end
  end

  def setup_options
    @options.show_tabs = true
  end

  def default_to_edit?
    @wiki.body.blank? && may_edit_page?
  end

end
