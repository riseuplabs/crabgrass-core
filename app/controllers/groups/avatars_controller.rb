class Groups::AvatarsController < Groups::BaseController

  include_controllers 'common/avatars'
  before_filter :setup

  protected

  # always enable cache, even in dev mode.
  def self.perform_caching; true; end
  def perform_caching; true; end

  def setup
    @entity = @group
    @success_url = group_settings_path(@group)
  end

end

