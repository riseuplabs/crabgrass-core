class Wikis::BaseController < ApplicationController

  permissions 'groups/members', 'groups/base'  # required to show the banner if wiki is owned by a group.

  before_filter :fetch_wiki
  before_filter :fetch_context

  helper 'wikis/base'

  include Wikis::BaseHelper # for the wiki_path

  protected
  def fetch_wiki
    @wiki = Wiki.find(params[:wiki_id])
  end

  def fetch_context
    @page = @wiki.page
    @group = @wiki.group
    @context = Context.find(@group || @page)
  end

end
