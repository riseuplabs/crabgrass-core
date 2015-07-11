require_relative '../../test_helper'

class Me::NoticesControllerTest < ActionController::TestCase
  fixtures :users, :notices

  def setup
    @blue = users(:blue)
    assert_not_empty @blue.notices.where(dismissed: false)
    login_as @blue
  end

  def test_destroy_all_html
    request.env["HTTP_REFERER"] = 'http://0.0.0.0:3000/me'
    delete :destroy_all
    assert_empty @blue.notices.where(dismissed: false)
    assert_redirected_to :back
  end

  def test_destroy_all_ajax
    xhr :delete, :destroy_all
    assert_empty @blue.notices.where(dismissed: false)
    assert_response :success
  end

end

