class Groups::CouncilsController < Groups::CommitteesController

  before_filter :login_required

  def new
    @council = Council.new
  end

  def create
    @council = Council.create params[:council].merge(:created_by => current_user)
    @group.add_committee!(@council)
    redirect_to group_url(@council)
    success
  end

end
