class Groups::AvatarsController < Groups::BaseController

  include_controllers 'common/avatars'
  include_controllers 'common/always_perform_caching'
  before_filter :setup
  skip_before_filter :login_required
  cache_sweeper :group_sweeper

  guard :allow

  protected

  def setup
    @entity = @group
    @success_url = group_settings_path(@group)
  end

end

