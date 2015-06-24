require 'test_helper'

class StarsControllerTest < ActionController::TestCase

  def setup
    @post = FactoryGirl.create :post
    @user = FactoryGirl.create :user
    login_as @user
  end

  def test_create
    assert_difference('Star.count') do
      xhr :post, :create, post_id: @post
    end

    assert_response :success
    assert assigns(:star).tap {|star|
      assert star.persisted?
      assert_equal @user, star.user
      assert_equal @post, star.starred
    }

    assert_equal 1, @post.reload.stars_count
  end

  def test_destroy
    @post.stars.create!(user: @user)
    assert_difference('Star.count', -1) do
      xhr :delete, :destroy, post_id: @post
    end
    assert_equal 0, @post.stars_count

    assert_response :success
  end
end
