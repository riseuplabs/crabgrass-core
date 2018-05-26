#
#     group_members GET    /groups/:group_id/members          {:action=>"index"}
#                   DELETE /groups/:group_id/members/:id      {:action=>"destroy"}
#                   POST   /groups/:group_id/members/:id?user_name=x      {:action=>"create"}
#

class Group::MembershipsController < Group::BaseController

  after_action :verify_authorized, only: %i[index create destroy]

  #
  # list all the memberships
  #
  def index
    authorize @group, :may_list_memberships?
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
    authorize @membership
    @group.remove_user! @user # memberships must be destroyed via group.remove_user!
  end

  #
  # add someone directly to a group
  #
  def create
    authorize @group, :may_create_membership?
    raise_not_found unless @group && @user
    @group.add_user! @user
    index # load @memberships
    success
  end

  protected

  def fetch_group
    super
    if action?(:destroy)
      if federation_view?
        @membership = @group.federatings.find(params[:id])
      else
        @membership = @group.memberships.find(params[:id])
        @user = @membership.user
      end
    elsif action?(:create)
      @user = User.find_by_login(params[:user_name]) if params[:user_name]
    end
  end

  def federation_view?
    params[:view] == 'groups'
  end
  helper_method :federation_view?
end
