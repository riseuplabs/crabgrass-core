require File.dirname(__FILE__) + '/../../test_helper'

class Me::DestroysControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
  end

  def test_not_logged_in
    get :show
    assert_login_required
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
    post :update, scrub_name: 1
    # we will only have a UserGhost if we load the user again...
    assert_nil User.find(@user.id).read_attribute :display_name
  end

end
