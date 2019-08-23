require 'test_helper'

class DiscussionPageControllerTest < ActionController::TestCase

  def test_show
    page = DiscussionPage.where(public: true).first
    get :show, params: { id: page.id }
    assert_response :success
  end

  def test_print
    login_as users(:blue)
    page = pages(:committee_page)
    get :print, params: { id: page.id }
    assert_response :success
  end
end
