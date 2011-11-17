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

  def new
    @profile = params[:private] ? @group.profiles.private : @group.profiles.public
    if @wiki = @profile.wiki # this is in case the wiki has been saved by another user since the link to new was created
      render :template => '/common/wiki/show'
    else
      @wiki = Wiki.new
      render :template => '/common/wiki/edit'
    end
  end

  def create
    if !params[:cancel]
      @profile = params[:wiki][:private] ? @group.profiles.private : @group.profiles.public
      if @wiki = @profile.wiki
        # if another user has since saved this group wiki, then we will save this one as a newer version
        @wiki.update_document!(current_user, nil, params[:wiki][:body])
      else
        @wiki = @profile.create_wiki(:version => 0, :body => params[:wiki][:body])
      end
    end
    #TODO: need to unlock when cancelling, as will still be locked
    #TODO: i would think create.rjs would not work right when cancelling but it seems okay. specifically, i would think it would always toggle the public wiki, but it doesn't seem to.

    #render :template => '/common/wiki/show' #redirect doesn't work correctly in firefox 3.6.23 (and maybe other versions), so we will render template
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
