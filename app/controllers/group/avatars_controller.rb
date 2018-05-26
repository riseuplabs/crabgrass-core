class Group::AvatarsController < Group::BaseController
  include_controllers 'common/avatars'
  include_controllers 'common/always_perform_caching'
  before_filter :setup

  # TODO: :verify_authorized should be set to false.
  after_action :verify_authorized, only: :index

  protected

  def setup
    @entity = @group
    @success_url = group_settings_path(@group)
  end
end
