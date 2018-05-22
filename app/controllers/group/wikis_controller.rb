class Group::WikisController < Group::BaseController
  guard :may_edit_group?

  def create
    if params[:profile] == 'private'
      @profile = @group.profiles.private
    elsif params[:profile] == 'public'
      @profile = @group.profiles.public
    else
      raise ErrorMessage, 'missing profile parameter'
    end
    wiki = @profile.create_wiki version: 0, body: '', user: current_user
    redirect_to action: :index, anchor: params[:profile]
  end

  def index
    @private_wiki = @group.private_wiki
    @public_wiki  = @group.public_wiki
  end
end
