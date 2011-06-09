require File.dirname(__FILE__) + '/../../test_helper'

class Me::SettingsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
  end

  def test_not_logged_in
    get :show
    assert_login_required
  end

end
