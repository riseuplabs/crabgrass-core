class Me::PermissionsController < Me::BaseController

  helper 'acts_as_locked'

  def index
    @keys  = current_user.keys.filter_by_holder(:include => [:public, current_user.friends, current_user.peers])
    @locks = User.locks
    render :template => 'common/permissions/index'
  end

  def update
    @key   = current_user.keys.find_or_create_by_keyring_code params.delete(:id)
    @locks = @key.update!(params)
    @keys  = current_user.keys.filter_by_holder(:include => [:public, current_user.friends, current_user.peers])
    render :template => 'common/permissions/update'
  end

  protected

  def key_holder_path(id)
    me_permission_path(id)
  end
  helper_method :key_holder_path

end
