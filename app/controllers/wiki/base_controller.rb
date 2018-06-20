class Wiki::BaseController < ApplicationController
  before_filter :fetch_wiki
  before_filter :login_required
  after_action :verify_authorized

  helper 'wikis/base'

  protected

  def fetch_wiki
    @wiki = Wiki.find(params[:wiki_id] || params[:id])
    @page = @wiki.page
    if params[:section].present?
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
