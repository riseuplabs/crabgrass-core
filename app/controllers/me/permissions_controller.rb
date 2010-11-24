class Me::PermissionsController < Me::BaseController

  def index
    @permissions = current_user.permissions #.without_self
  end

  def create
    @permission = current_user.allow! params[:permission][:entity_code], :view
    if @permission
      redirect_to me_permissions_url, :notice => 'Permission added'
    else
      render :action => :new
    end
  end

  def update
    @permission = current_user.permissions.find params[:id]
    @permission.update_attributes! params[:permission]
    success
    redirect_to me_permissions_url
  end

  def destroy
    @permission = current_user.permissions.find params[:id]
    @permission.destroy
    redirect_to me_permissions_url
  end

end
