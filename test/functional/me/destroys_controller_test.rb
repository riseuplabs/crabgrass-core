require 'test_helper'

class Me::DestroysControllerTest < ActionController::TestCase
  def setup
    @user = users(:blue)
  end

  def test_not_logged_in
    get :show
    assert_login_required
  end

  def test_update
    login_as @user
    post :update
    assert_equal @user.display_name, @user.reload.display_name
    assert_nil @user.reload.password_digest
    assert_equal [], @user.keys
  end

  def test_update_scrub_name
    login_as @user
    post :update, params: { scrub_name: true }
    # we will only have a User::Ghost if we load the user again...
    assert_nil User.find(@user.id).read_attribute :display_name
  end

  def test_notification
    expecting_notifications :user_destroyed, to: @user.friends do
      login_as @user
      post :update, params: { scrub_name: 1 }
    end
  end

  def expecting_notifications(event, to:, &block)
    notification_mock = Minitest::Mock.new
    notification_mock.expect :create_notices_for, nil, [to]
    method_mock = Minitest::Mock.new
    method_mock.expect :call, notification_mock, [event, Hash]
    Notification.stub :new, method_mock, &block
    method_mock.verify
    notification_mock.verify
  end
end
