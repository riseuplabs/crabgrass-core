class Me::PermissionsController < Me::BaseController

  def index
    @keys = current_user.keys
    @locks = User.locks
  end

  def update
    @key = current_user.keys.find_by_keyring_code params.delete(:id)
    @locks = @key.update!(params)
    @keys = current_user.keys
    success
  end

end
