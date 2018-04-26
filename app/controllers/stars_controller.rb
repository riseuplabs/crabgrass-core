#
# StarsController
#
# Add and remove stars from posts and maybe other things in the future.
#
# We rely on the stars_count counter cache in the starred object. So please
# stick to functions based on the association such as
#   @starred.stars.create
# to make sure the counter_cache of the associated object is updated.
#
# We redirect to the starred object (post) which will rerender it on
# the page.
# This way we can ignore all error cases because the current state will be
# rendered to the view either way. So if a post already was starred and
# a user tries to star it again it will just see the starred post when the
# request returns - no need for an error message.
#
# The redirect also means that page reloads work nicely. They do not trigger
# the starring again. In the long run it may also allow us to benefit from
# turbo links as turbo links handles GET requests only - which include GETs as
# a result of redirects.
#
class StarsController < ApplicationController
  include Common::Tracking::Action

  before_filter :fetch_starred

  def create
    @starred.stars.create(user: current_user)
    redirect_to @starred
  end

  def destroy
    # do not trigger callbacks but decrement stars_count on @starred
    @starred.stars.delete(@star) if @star
    redirect_to @starred
  end

  private

  def fetch_starred
    @starred = Post.find(params[:post_id])
    @star = @starred.stars.where(user_id: current_user).first
    # Prevent sending notifcation if the action will result in a noop.
    # redirects in a before filter skip the action and after_filters.
    redirect_to @starred if @star.blank? && action?(:destroy)
    redirect_to @starred if @star.present? && action?(:create)
  end

  def track_action
    super from: current_user, user: @starred.user,
          noticable: @starred
  end
end
