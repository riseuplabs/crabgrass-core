class Groups::PermissionsController < Groups::BaseController

  before_filter :login_required
  helper 'castle_gates'

  def index
    @holders = key_holders(:public)
  end

  def update
    # update
    gate = @group.gate(params.delete(:gate).to_sym)
    new_state = params[:new_state]
    if new_state == 'open'
      @group.grant_access!(:public => gate.name)
    else
      @group.revoke_access!(:public => gate.name)
    end

    # render
    @holders = key_holders(:public)
    success :saved.t, :quick
    render :update do |page|
      standard_update(page)
      page.replace_html 'permissions_area', :file => 'groups/permissions/index'
    end

  end

  protected

  def key_holder_path(id, *args)
    group_permission_path(@group, id, *args)
  end
  helper_method :key_holder_path

end

