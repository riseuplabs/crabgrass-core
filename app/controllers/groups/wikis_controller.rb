class Groups::WikisController < Groups::BaseController

  include_controllers 'common/wiki'

  # show might be allowed when not logged in
  before_filter :login_required, :except => :show
  before_filter :authorized?, :only => :show

  layout proc{ |c| c.request.xhr? ? false : 'sidecolumn' }

  def new
    if @wiki = @profile.wiki
      # the wiki has been saved by another user since the link to
      # new was displayed
      render :template => '/common/wiki/show'
    else
      @wiki = Wiki.new
      render :template => '/common/wiki/edit'
    end
  end

  def create
    if !params[:cancel]
      if @wiki = @profile.wiki
        # another user has created this group wiki
        # we will save this one as a newer version
        @wiki.update_document!(current_user, nil, params[:wiki][:body])
      else
        @wiki = @profile.create_wiki(:version => 0, :body => params[:wiki][:body])
      end
    end
    redirect_to entity_path(@group || @page)
  end


  protected

  def fetch_context
    @group = Group.find_by_name(params[:group_id])
    @profile = fetch_private? ?
      @group.profiles.private :
      @group.profiles.public
  end

  def fetch_private?
    params[:wiki] && params[:wiki][:private] or
    params[:private]
  end

  def fetch_wiki
    @wiki = @group.wikis.find(params[:id]) # this could be nil
  end

end
