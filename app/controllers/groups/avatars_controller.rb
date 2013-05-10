class Groups::AvatarsController < Groups::BaseController

  include_controllers 'common/avatars'
  before_filter :setup
  skip_before_filter :login_required
  cache_sweeper :group_sweeper

  # always enable cache, even in dev mode.
  def self.perform_caching; true; end
  def perform_caching; true; end

  protected

  def setup
    @entity = @group
    @success_url = group_settings_path(@group)
  end

end

