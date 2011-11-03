class Groups::WikisController < Groups::BaseController

  include_controllers 'common/wiki'

  protected

  def fetch_context
    @group = Group.find_by_name(params[:group_id])
  end

  def fetch_wiki
    @wiki = @group.wikis.find(params[:id])
  end

end
