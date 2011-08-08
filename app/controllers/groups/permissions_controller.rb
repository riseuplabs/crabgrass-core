
class Groups::PermissionsController < Groups::BaseController

  helper 'acts_as_locked'

  def index
    @keys  = @group.keys.filter_by_holder(:include => [:public], :exclude => [@group])
    @locks = locks
  end

  def update
    @key   = @group.keys.find_or_create_by_keyring_code params.delete(:id)
    @locks = @key.update!(params)
    @locks = locks
    @keys  = @group.keys.filter_by_holder(:include => [:public], :exclude => [@group])
    render :template => 'common/permissions/update'
  end

  protected

  def key_holder_path(id)
    group_permission_path(@group, id)
  end
  helper_method :key_holder_path

  def locks
    arry = [:view, :see_members, :request_membership]
    arry << :see_committees if Conf.committees
    arry << :see_networks if Conf.networks
    return arry
  end

end

