class Wikis::BaseController < ApplicationController

  before_filter :fetch_wiki

  permissions 'wikis'
  before_filter :login_required
  guard :may_edit_wiki?

  permission_helper 'groups/memberships', 'groups/base'

  helper 'wikis/base'

  protected

  def fetch_wiki
    @wiki = Wiki.find(params[:wiki_id] || params[:id])
    @page = @wiki.page
    if params[:section]
      @section = params[:section]
      @body = @wiki.get_body_for_section(@section)
    else
      @section = :document
      @body = @wiki.body
    end
  end

  def setup_context
    @context = Context.find(@wiki.context) if @wiki.context
    super
  end

end
