=begin

 WikiController

 This is the controller for the in-place wiki editor, not for the
 the wiki page type (wiki_page_controller.rb).

=end

class Wikis::WikisController < Wikis::BaseController

  skip_before_filter :login_required, :only => :show
  before_filter :authorized?, :only => :show

  guard :show => :may_show_wiki?

  helper 'wikis/sections'
  javascript 'upload', :only => :edit
  stylesheet 'wiki_edit'
  stylesheet 'upload', :only => :edit

  layout proc{ |c| c.request.xhr? ? false : 'sidecolumn' }

  def show
    render :template => '/common/wiki/show',
      :locals => {:preview => params['preview']}
  end

  def print
    render :template => 'common/wiki/show',
      :layout => "printer_friendly"
  end

  def edit
    if params[:break_lock]
      # remove other peoples lock if it exists
      @wiki.unlock!(:document, current_user, :break => true )
    end
    if @wiki.document_open_for?(current_user)
      @wiki.lock!(:document, current_user)
    else
      render :template => '/wikis/wikis/locked'
    end
  end

  def update
    if params[:cancel]
      @wiki.unlock!(:document, current_user, :break => true ) if @wiki
    else
      @wiki.update_document!(current_user, params[:wiki][:version], params[:wiki][:body])
      success
    end
    redirect_to @page ? page_url(@page) : entity_path(@wiki.context)

  rescue Wiki::VersionExistsError, Wiki::SectionLockedOnSaveError => exc
    warning exc
    @wiki.body = params[:wiki][:body]
    @wiki.version = @wiki.versions.last.version + 1
    # this won't unlock if they don't hit save:
    @wiki.unlock!(:document, current_user, :break => true )
    render :template => '/wikis/wikis/edit'
  end

end
