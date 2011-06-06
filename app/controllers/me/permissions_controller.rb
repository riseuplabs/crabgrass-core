class Me::PermissionsController < Me::BaseController

  def index
    @keys = current_user.keys
    @locks = User.locks
  end

  def update
    @keys = current_user.keys
    @key = @keys.find_by_keyring_code params.delete(:id)
    @locks = @key.update!(params)
    success
  end

end
