class Groups::GroupsController < Groups::BaseController

  def new
    @group = Group.new
  end

  def create
    @group = Group.create! params[:group]
    redirect_to group_url(@group)    
    success
  end

  def destroy
  end

end


