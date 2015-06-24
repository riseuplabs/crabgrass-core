class StarsController < ApplicationController

  before_filter :fetch_starred

  def create
    @star = @starred.stars.create!(user: current_user)
    success
  end

  def destroy
    @star = @starred.stars.where(user_id: current_user).first
    raise_not_found("No star to remove") unless @star
    # do not trigger callbacks but decrement stars_count on @starred
    @starred.stars.delete(@star)
    success
  end

  private

  def fetch_starred
    @starred = Post.find(params[:post_id])
  end

  def track_action
  #    TwinkledActivity.create!(
  #      :user => @post.user, :twinkler => current_user,
  #      :post => {:id => @post.id, :snippet => @post.body[0..30]}
  #    )
  #  end
  end

end
