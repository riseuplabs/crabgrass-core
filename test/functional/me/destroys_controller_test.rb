require 'test_helper'

class Me::DestroysControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    @user  = users(:blue)
  end

  def test_not_logged_in
    assert_login_required do
      get :show
    end
  end

  def test_update
    login_as @user
    post :update
    assert_equal @user.display_name, @user.reload.display_name
    assert_nil @user.reload.crypted_password
    assert_equal [], @user.keys
  end

  def test_update_scrub_name
    login_as @user
    post :update, scrub_name: true
    # we will only have a User::Ghost if we load the user again...
    assert_nil User.find(@user).read_attribute :display_name
  end

  def test_notification
    notification_mock(:user_destroyed, username: @user.name).
      expects(:create_notices_for).
      with(@user.friends)

    login_as @user
    post :update, scrub_name: 1
  end

  def notification_mock(*args)
    mock('notification').tap do |mock|
      Notification.expects(:new).with(*args).returns mock
    end
  end

end
