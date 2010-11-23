class Me::PermissionsController < Me::BaseController

  def index
    @permissions = current_user.permissions #.without_self
  end

  def show
    @permission = current_user.permissions.find params[:id]
  end

  def new
    @permission = Permission.new
  end

  def create
    @permission = Permission.new params[:permission]
    if @permission.save
      redirect_to @permission, :notice => 'Permission added'
    else
      render :action => :new
    end
  end

  def edit
    @permission = current_user.permissions.find params[:id]
  end

  def update
    @permission = current_user.permission.find params[:id]
    @permission.update_attributes! params[:permission]
    success
    redirect_to @permission
  end

  def destroy
    @permission = current_user.permissions.find params[:id]
    @permission.destroy
    redirect_to me_permissions_url
  end

end
