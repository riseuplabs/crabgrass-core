#
#     group_members GET    /groups/:group_id/members          {:action=>"index"}
#                   POST   /groups/:group_id/members          {:action=>"create"}
#  new_group_member GET    /groups/:group_id/members/new      {:action=>"new"}
# edit_group_member GET    /groups/:group_id/members/:id/edit {:action=>"edit"}
#      group_member GET    /groups/:group_id/members/:id      {:action=>"show"}
#                   PUT    /groups/:group_id/members/:id      {:action=>"update"}
#                   DELETE /groups/:group_id/members/:id      {:action=>"destroy"}
#

class Groups::MembersController < Groups::BaseController

  before_filter :fetch_membership

  def index
    @memberships = @group.memberships.paginate(pagination_params)
  end

  def destroy
    @membership.destroy
    render :update do |page|
      page.hide dom_id(@membership)
    end
  end

  protected

  def fetch_membership
    @membership = @group.memberships.find(params[:id]) if params[:id]
  end

end

