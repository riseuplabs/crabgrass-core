class Wikis::BaseController < ApplicationController


  before_filter :fetch_wiki
  before_filter :fetch_context

  helper 'wikis/base'

  include Wikis::BaseHelper # for the wiki_path

  protected
  def fetch_wiki
    @wiki = Wiki.find(params[:wiki_id])
  end

  # TODO  We might want to clean this up by mowing the logic into the model like
  #   @context = @wiki.context
  def fetch_context
    if @wiki.pages.any?
      @page = @wiki.pages.first
    else
      @group = @wiki.group
    end
  end

end
