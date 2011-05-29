class Me::PermissionsController < Me::BaseController

  def index
    @keys_by_lock = current_user.keys_by_lock
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
    @key = current_user.keys.find_by_keyring_code params.delete(:id)
    @locks = @key.update!(params)
    success
  end

#  def destroy
#    @permission = current_user.permissions.find params[:id]
#    @permission.destroy
#    redirect_to me_permissions_url
#  end

end
