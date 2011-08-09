class Groups::CouncilsController < Groups::CommitteesController

  def new
    @council = Council.new
  end

  def create
    @council = Council.create! params[:group].merge(:created_by => current_user)
    @parent.add_committee!(@council) #?
    redirect_to group_url(@council)
    success
  end

end
