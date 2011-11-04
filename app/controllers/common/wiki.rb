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
    end
  end

  def show
    render :template => '/common/wiki/show'
  end

  def preview
    render :template => '/common/wiki/show', :locals => {:preview => true}
  end

  def new
    @wiki = Wiki.new
    # @wiki.lock!(:document, current_user) #this won't work, as @wiki isn't properly set at this point, and even @wiki.save! doesn't do it correctly
    render :template => '/common/wiki/new'
  end

  def create
    if !params[:cancel]
      @profile = params[:wiki][:private] ? @group.profiles.private : @group.profiles.public
      @wiki = @profile.create_wiki(:version => 0, :body => params[:wiki][:body])
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
    @wiki.lock!(:document, current_user) if @wiki.document_open_for?(current_user)
    render :template => '/common/wiki/edit'
  end

  def update
    if params[:cancel]
      @wiki.unlock!(:document, current_user, :break => true ) if @wiki
    else
      @wiki.update_document!(current_user, params[:wiki][:version], params[:wiki][:body])
    end
  end

  protected

  def setup_wiki_rendering
    return unless @wiki
    @wiki.render_body_html_proc {|body| render_wiki_html(body, @group.name)}
  end
end
