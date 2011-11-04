class Groups::WikisController < Groups::BaseController

  include_controllers 'common/wiki'

  protected

  def fetch_context
    @group = Group.find_by_name(params[:group_id])
  end

  def fetch_wiki
    # TODO: this will require group has_many :wikis :through => :profiles
    @wiki = @group.wikis.find_by_id(params[:id]) #this could be nil
  end

end
