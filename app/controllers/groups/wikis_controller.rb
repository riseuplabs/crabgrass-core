class Groups::WikisController < Groups::BaseController

  guard :may_edit_group?

  permission_helper 'wikis'
  helper 'wikis/base'

  def new
    if @wiki = @profile.wiki
      # the wiki has been created by another user since the link to
      # new was displayed - so we reload the group home instead.
      render :template => '/groups/home/reload'
    else
      @wiki = Wiki.new :private => fetch_private?
      render :template => '/wikis/wikis/edit'
    end
  end

  def create
    if !params[:cancel]
      if @wiki = @profile.wiki
        # another user has created this group wiki
        # we will save this one as a newer version
        @wiki.update_document!(current_user, nil, params[:wiki][:body])
        notice :wiki_existed_new_version_created.t
      else
        @wiki = @profile.create_wiki :version => 0,
          :body => params[:wiki][:body],
          :user => current_user
        success
      end
    end
    redirect_to entity_path(@group || @page)
  end


  protected

  def fetch_group
    # @group is fetched in Groups::BaseController
    super
    @profile = fetch_private? ?
      @group.profiles.private :
      @group.profiles.public
  end

  def fetch_private?
    priv = params[:wiki] ? params[:wiki][:private] : params[:private]
    priv && priv.any?
  end

  def fetch_wiki
    @wiki = @group.wikis.find(params[:id]) # this could be nil
  end

end
