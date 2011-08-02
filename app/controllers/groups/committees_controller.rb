class Groups::CommitteesController < Groups::BaseController

prepend_before_filter :get_parent

  def new
    @group = Committee.new
  end

  def create
    @group = Committee.create! params[:group].merge(:created_by => current_user)
    @parent.add_committee!(@group) #?
    redirect_to group_url(@group)    
    success
  end

  protected

  def get_parent
      @parent = Group.find_by_name(params[:group_id])
  end
end

