class Me::AvatarsController < Me::BaseController
  include_controllers 'common/avatars'
  include_controllers 'common/always_perform_caching'
  before_action :setup

  def destroy
    if avatar = @entity.avatar
      expire_avatar(avatar)
      avatar.destroy
      @entity.avatar = nil
      @entity.increment!(:version)
    end
  ensure
    redirect_to @success_url
  end

  protected

  def setup
    @entity = current_user
    @success_url = me_settings_url
  end

  def user_avatars_path(_user, avatar)
    me_avatar_path(avatar)
  end
  helper_method :user_avatars_path
end
