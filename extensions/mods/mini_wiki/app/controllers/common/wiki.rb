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

  def update
    begin
      @wiki.update_document!(current_user, params[:version], params[:body])
      unlock_for_current_user
    rescue Exception => exc
      @message = exc.to_s
      return render(:action => 'error') # TODO: this should not be an action
    end
    render :template => '/common/wiki/update'
  end

  protected

  def setup_wiki_rendering
    return unless @wiki
    @wiki.render_body_html_proc {|body| render_wiki_html(body, @group.name)}
  end
end
