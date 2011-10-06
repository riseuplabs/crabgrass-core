class Widget::MiniWikiController < ApplicationController

  permissions 'widget/wiki'

  before_filter :fetch_context
  before_filter :login_required
  before_filter :fetch_wiki
  before_filter :setup_wiki_rendering

  def show
  end

  def edit
    @wiki.lock!(:document, current_user) if @wiki.document_open_for?(current_user)
  end

  def update
    begin
      @wiki.update_document!(current_user, params[:version], params[:body])
      unlock_for_current_user
    rescue Exception => exc
      @message = exc.to_s
      return render(:action => 'error') # TODO: this should not be an action
    end
  end

  protected

  def fetch_context
    if params[:group_id]
      @group = Group.find_by_name(params[:group_id])
    elsif params[:page_id]
      @page = Page.find(params[:page_id])
    end
  end

  def fetch_wiki
    @wiki = (@group || @page)Wiki.find(params[:id])
  end

  def setup_wiki_rendering
    return unless @wiki
    @wiki.render_body_html_proc {|body| render_wiki_html(body, @group.name)}
  end
end
