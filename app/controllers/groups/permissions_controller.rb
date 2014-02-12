class Groups::PermissionsController < Groups::BaseController

  before_filter :login_required
  helper 'castle_gates'

  def index
    @holders = key_holders(:public)
  end

  def update
    # update
    gate = @group.gate(params.delete(:gate))
    new_state = params[:new_state]

    if params[:id].to_i == 0
      holder = :public
    else
      holder = CastleGates::Holder.find_by_code(params[:id])
      # don't allow altering any other holder than :public or
      # the group itself.
      # otherwise you could do all kinds of nasty things.
      if holder != @group
        render :status => 400, :text => '' and return
      end
    end

    ## FIXME: should we prevent the following cases?
    ##  - granting :admin to :public
    ##  - granting :admin to @group, when @group has a council
    ##  - ...

    if new_state == 'open'
      @group.grant_access!(holder => gate.name)
    else
      @group.revoke_access!(holder => gate.name)
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

