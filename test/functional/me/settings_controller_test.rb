require File.dirname(__FILE__) + '/../../test_helper'

class Me::SettingsControllerTest < ActionController::TestCase

  def setup
    @user = User.make
  end

  def test_not_logged_in
    assert_login_required do
      get :show
    end
  end



end
