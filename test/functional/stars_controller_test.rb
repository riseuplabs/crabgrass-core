require 'test_helper'

class StarsControllerTest < ActionController::TestCase
  def setup
    @page = FactoryBot.create :page
    @user = FactoryBot.create :user
    @post = @page.add_post(@user, body: 'test post')
    login_as @user
  end

  def test_create
    assert_difference('Star.count') do
      post :create, params: { post_id: @post }, xhr: true
    end

    assert_response :redirect
    star = Star.last
    assert_equal @user, star.user
    assert_equal @post, star.starred

    assert_equal 1, @post.reload.stars_count
  end

  def test_destroy
    @post.stars.create!(user: @user)
    assert_difference('Star.count', -1) do
      delete :destroy, params: { post_id: @post }, xhr: true
    end
    assert_equal 0, @post.reload.stars_count

    assert_response :redirect
  end
end
