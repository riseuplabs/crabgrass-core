class Me::PermissionsController < Me::BaseController

  helper 'castle_gates'

  def index
    @holders = key_holders(:public, current_user.associated(:peers), current_user.associated(:friends))
    @gates   = current_user.gates
  end

  def update
    @key   = current_user.keys.find_or_create_by_keyring_code params.delete(:id)
    @locks = @key.update!(params)

    @holders = [:public, current_user.associated(:peers), current_user.associated(:friends)]
    @keys  = current_user.keys.limited_by_holders(@holders).all
    render :template => 'common/permissions/update'
  end

  protected

  def key_holder_path(id)
    me_permission_path(id)
  end
  helper_method :key_holder_path

end
