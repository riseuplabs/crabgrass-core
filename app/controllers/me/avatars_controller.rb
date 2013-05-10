class Me::AvatarsController < Me::BaseController

  include_controllers 'common/avatars'
  before_filter :setup
  cache_sweeper :user_sweeper

  # always enable cache, even in dev mode.
  def self.perform_caching; true; end
  def perform_caching; true; end

  protected
  def setup
    @entity = current_user
    @success_url = me_settings_url
  end

  def user_avatars_path(user)
    me_avatars_path
  end
  helper_method :user_avatars_path

end

