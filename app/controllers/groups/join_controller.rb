class Groups::JoinController < Groups::BaseController

  #before_filter :login_required
  permissions 'requests'  
  #include_controllers 'common/requests' #???
   
  def new
  end
  
  def create
    #return unless may_join_memberships?  #? 
    @group.add_user!(current_user) # commented to test
    redirect_to entity_url(@group)
  end

  def destroy
    @group.remove_user!(current_user)
    redirect_to me_home_path
  end

  protected
  
  def authorized?
    if action?('create', 'new')
      may_join_memberships?
    elsif action == 'destroy'
      may_leave_memberships?
    end
  end
  
end
