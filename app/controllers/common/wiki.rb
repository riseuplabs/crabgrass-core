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
      before_filter :fetch_wiki, :only => [:show, :edit, :update]
      before_filter :setup_wiki_rendering
    end
  end

  def show
    render :template => '/common/wiki/show'
  end

  def new
    render :template => '/common/wiki/new'
  end

  def create
    render :template => '/common/wiki/create'
  end

  def edit
    @wiki.lock!(:document, current_user) if @wiki.document_open_for?(current_user)
    render :template => '/common/wiki/edit'
  end

  #def cancel #test but did not work
   # render :template => '/common/wiki/show'
  #end

  def update
    #begin
    if !params[:cancel] #super hacky to have this if condition, but test for now
      @wiki.update_document!(current_user, params[:wiki][:version], params[:wiki][:body])
    end
    #unlock_for_current_user
    #rescue Exception => exc
    #  @message = exc.to_s
    #  return render :partial => 'common/wiki/error'#(:action => 'error') # TODO: this should not be an action
    #end
    #render :template => '/common/wiki/update'
    #redirect_to :action => :show # should be right ***
    render :template => '/common/wiki/show' #probably not ideal but works for now.
  end

  protected

  def setup_wiki_rendering
    return unless @wiki
    @wiki.render_body_html_proc {|body| render_wiki_html(body, @group.name)}
  end
end
