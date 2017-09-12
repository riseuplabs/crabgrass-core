require 'test_helper'

class StarTest < ActiveSupport::TestCase
  def setup
    @post = FactoryGirl.create :post
    @user = FactoryGirl.create :user
  end

  def test_counter_cache_increment
    assert_equal 0, @post.stars_count
    @post.stars.create!(user: @user)
    assert_equal 1, @post.reload.stars_count
  end

  def test_can_only_star_once
    assert_equal 0, @post.stars_count
    assert_difference 'Star.count' do
      @post.stars.create(user: @user)
      @post.stars.create(user: @user)
    end
    assert_equal 1, @post.reload.stars_count
  end

  def test_counter_cache_decrement
    @star = @post.stars.create!(user: @user)
    assert_equal 1, @post.reload.stars_count
    @post.stars.delete(@star)
    assert_equal 0, @post.stars_count
  end
end
