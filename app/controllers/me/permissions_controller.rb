class Me::PermissionsController < Me::BaseController

  def index
    @keys = current_user.keys
    @locks = User.locks
  end

  def create
    @permission = current_user.grant! params[:permission][:keyring_code], :view
    if @permission
      redirect_to me_permissions_url, :notice => 'Permission added'
    else
      render :action => :new
    end
  end

  def update
    @keys = current_user.keys
    @key = @keys.find_by_keyring_code params.delete(:id)
    @locks = @key.update!(params)
    success
  end

#  def destroy
#    @permission = current_user.permissions.find params[:id]
#    @permission.destroy
#    redirect_to me_permissions_url
#  end

end
