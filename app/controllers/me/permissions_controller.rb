class Me::PermissionsController < Me::BaseController
  helper 'castle_gates'

  def index
    @holders = key_holders(:public, current_user.associated(:peers), current_user.associated(:friends))
  end

  def update
    # update
    holder = find_holder_by_code(params.delete(:id))
    gate = current_user.gate(params.delete(:gate))
    new_state = params[:new_state]
    if new_state == 'open'
      current_user.grant_access!(holder => gate.name)
    else
      current_user.revoke_access!(holder => gate.name)
    end

    # render
    @holders = key_holders(:public, current_user.associated(:peers), current_user.associated(:friends))
    success :saved.t, :quick
  end

  protected

  def key_holder_path(id, *args)
    me_permission_path(id, *args)
  end
  helper_method :key_holder_path
end
