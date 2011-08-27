#
#     group_members GET    /groups/:group_id/members          {:action=>"index"}
#                   DELETE /groups/:group_id/members/:id      {:action=>"destroy"}
#

class Groups::MembersController < Groups::BaseController

  before_filter :fetch_membership, :only => :destroy
  before_filter :login_required

  def index
    @memberships = @group.memberships.paginate(pagination_params)
  end

  #
  # this is a little odd. we use MembersController#destroy for
  # removing other people, but MembershipsController#destroy for
  # removing ourselves.
  #
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

