class Group::MyMembershipsController < Group::BaseController

  def create
    authorize @membership
    @group.add_user!(current_user)
    redirect_to entity_url(@group)
  end

  def destroy
    authorize @membership
    @group.remove_user!(current_user)
    if current_user.may?(:view, @group)
      redirect_to entity_url(@group)
    else
      redirect_to me_home_url
    end
  end
end
