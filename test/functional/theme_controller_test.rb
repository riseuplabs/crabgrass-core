require 'test_helper'

#
# very basic test that ensures the main code path gets triggered
#
class ThemeControllerTest < ActionController::TestCase
  def test_show
    get :show, params: { name: :default, file: :bla }
    assert_response :success
  end
end
