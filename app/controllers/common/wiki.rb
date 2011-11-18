=begin

 WikiController

 This is the controller for the in-place wiki editor, not for the
 the wiki page type (wiki_page_controller.rb).

 Everything here is entirely ajax, for now.

=end
module Common::Wiki

  def self.included(base)
    base.class_eval do
      before_filter :fetch_context # needs to be defined in the controller itself
      before_filter :login_required # will use the permissions from the controller
      before_filter :fetch_wiki, :only => [:show, :preview, :edit, :update]
      before_filter :setup_wiki_rendering

      javascript :wiki
      stylesheet 'wiki_edit'

    end
  end

  def show
    render :template => '/common/wiki/show', :locals => {:preview => params['preview']}
  end

  def edit
    if params[:break_lock]
      # remove other peoples lock if it exists
      @wiki.unlock!(:document, current_user, :break => true )
    end
    if @wiki.document_open_for?(current_user)
      @wiki.lock!(:document, current_user)
      render :template => '/common/wiki/edit'
    else
      render :template => '/common/wiki/locked'
    end
  end

  def update
    if params[:cancel]
      @wiki.unlock!(:document, current_user, :break => true ) if @wiki
    else
      @wiki.update_document!(current_user, params[:wiki][:version], params[:wiki][:body])
    end
    redirect_to entity_path(@group || @page)

  rescue Wiki::VersionExistsError, Wiki::SectionLockedOnSaveError => exc
    warning exc
    @wiki.body = params[:wiki][:body]
    @wiki.version = @wiki.versions.last.version + 1
    # this won't unlock if they don't hit save:
    @wiki.unlock!(:document, current_user, :break => true )
    render :template => 'common/wiki/edit'
  end

  protected

  def setup_wiki_rendering
    return unless @wiki
    @wiki.render_body_html_proc {|body| render_wiki_html(body, @group.name)}
  end
end
