class Wikis::WikisController < Wikis::BaseController

  permissions :wikis
  before_filter :login_required, :except => :show

  javascript :wiki
  stylesheet 'wiki_edit'

  guard :edit => :may_edit_wiki?,
        :update => :may_edit_wiki?

  def edit
    if params[:break_lock]
      # remove other peoples lock if it exists
      @wiki.unlock!(:document, current_user, :break => true )
    end
    if @wiki.document_open_for?(current_user)
      @wiki.lock!(:document, current_user)
    else
      render :template => 'locked'
    end
  end

  def update
    if params[:cancel]
      @wiki.unlock!(:document, current_user, :break => true ) if @wiki
    else
      @wiki.update_document!(current_user, params[:wiki][:version], params[:wiki][:body])
      success
    end
    redirect_to @page ? page_url(@page) : entity_path(@group)

  rescue Wiki::VersionExistsError, Wiki::SectionLockedOnSaveError => exc
    warning exc
    @wiki.body = params[:wiki][:body]
    @wiki.version = @wiki.versions.last.version + 1
    # this won't unlock if they don't hit save:
    @wiki.unlock!(:document, current_user, :break => true )
    render :template => 'edit'
  end

end
