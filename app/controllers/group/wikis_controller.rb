class Group::WikisController < Group::BaseController
  guard :may_edit_group?
  permissions 'wikis'

  def create
    if params[:profile] == 'private'
      @profile = @group.profiles.private
    elsif params[:profile] == 'public'
      @profile = @group.profiles.public
    else
      raise ErrorMessage, 'missing profile parameter'
    end
    wiki = @profile.create_wiki version: 0, body: '', user: current_user
    params[:edit_mode] = 'on'
    redirect_to action: :index
  end

  def index
    @private_wiki = @group.private_wiki
    @public_wiki  = @group.public_wiki
  end
end
