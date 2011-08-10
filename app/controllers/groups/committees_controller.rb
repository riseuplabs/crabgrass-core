class Groups::CommitteesController < Groups::BaseController

  def new
    @committee = Committee.new
  end

  def create
    @committee = Committee.create params[:committee].merge(:created_by => current_user)
    @group.add_committee!(@committee)
    redirect_to group_url(@committee)
    success
  end

end
