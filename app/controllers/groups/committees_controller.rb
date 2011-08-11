class Groups::CommitteesController < Groups::BaseController

  def new
    @committee = Committee.new
  end

  def create
    @committee = Committee.new params[:committee].merge(:created_by => current_user)
    @committee.save!
    if @committee.valid?
      @group.add_committee!(@committee)
      redirect_to group_url(@committee)
      success
    end
  end

end
