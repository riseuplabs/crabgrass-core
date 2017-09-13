require 'test_helper'

class Me::NoticesControllerTest < ActionController::TestCase
  def setup
    @blue = users(:blue)
    assert_not_empty @blue.notices.where(dismissed: false)
    login_as @blue
  end

  def test_index
    get :index
    assert_response :success
  end

  # we should prevent this from happening in the first place.
  # However the landing page is such an important entry point
  # that we want to be sure to catch errors as well.
  def test_index_with_invalid_notice
    notice = Notice::PostStarredNotice.create user: @blue, noticable_type: 'Post',
                                              noticable_id: 987_654_321
    get :index
    assert_response :success
  end

  def test_destroy_all_html
    request.env['HTTP_REFERER'] = 'http://0.0.0.0:3000/me'
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
