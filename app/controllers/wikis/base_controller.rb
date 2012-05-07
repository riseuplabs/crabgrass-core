class Wikis::BaseController < ApplicationController

  permission_helper 'groups/memberships', 'groups/base'

  before_filter :fetch_wiki

  helper 'wikis/base'

  protected
  def fetch_wiki
    @wiki = Wiki.find(params[:wiki_id] || params[:id])
    @page = @wiki.page
  end

  def setup_context
    @context = Context.find(@wiki.context) if @wiki.context
    super
  end

end
