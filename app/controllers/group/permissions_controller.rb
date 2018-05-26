class Group::PermissionsController < Group::BaseController
  helper 'castle_gates'

  def index
    authorize @group, :admin?
    @holders = key_holders(:public)
  end

  def update
    authorize @group, :admin?
    gate = @group.gate(params.delete(:gate))
    new_state = params[:new_state]

    if params[:id].to_i == 0
      holder = :public
    else
      holder = CastleGates::Holder.find_by_code(params[:id])
      # don't allow altering any other holder than :public or
      # the group itself.
      # otherwise you could do all kinds of nasty things.
      head :bad_request and return if holder != @group
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

    # set state for render
    @holders = key_holders(:public)
    success :saved.t, :quick
  end

  protected

  def key_holder_path(id, *args)
    group_permission_path(@group, id, *args)
  end
  helper_method :key_holder_path
end
