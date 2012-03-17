#
#     group_members GET    /groups/:group_id/members          {:action=>"index"}
#                   DELETE /groups/:group_id/members/:id      {:action=>"destroy"}
#

class Groups::MembershipsController < Groups::BaseController

  before_filter :fetch_membership, :only => :destroy
  before_filter :login_required

  guard :index => :may_list_memberships?,
        :destroy => :may_destroy_membership?

  #
  # list all the memberships
  #
  def index
    if federation_view?
      @memberships = @group.federatings.paginate(pagination_params)
    else
      @memberships = @group.memberships.paginate(pagination_params)
    end
  end

  #
  # immediately destroy a membership
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

  def federation_view?
    params[:view] == 'groups'
  end
  helper_method :federation_view?

end

