class Groups::MyMembershipsController < Groups::BaseController

  before_filter :login_required
  guard :create => :may_join_group?,
        :destroy => :may_leave_group?
  
  def create
    @group.add_user!(current_user)
    redirect_to entity_url(@group)
  end

  def destroy
    @group.remove_user!(current_user)
    if current_user.may?(:view, @group)
      redirect_to entity_url(@group)
    else
      redirect_to me_home_url
    end
  end

end
