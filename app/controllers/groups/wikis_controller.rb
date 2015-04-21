class Groups::WikisController < Groups::BaseController

  guard :may_edit_group?
  permissions 'wikis'

  def create
    if params[:profile] == 'private'
      @profile = @group.profiles.private
    elsif params[:profile] == 'public'
      @profile = @group.profiles.public
    else
      raise_error 'missing profile parameter'
    end
    wiki = @profile.create_wiki version: 0, body: '', user: current_user
    params[:edit_mode] = 'on'
    index()
  end

  def index
    @private_wiki = @group.private_wiki
    @public_wiki  = @group.public_wiki
  end

end
