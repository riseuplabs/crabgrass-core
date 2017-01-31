require 'test_helper'

class DiscussionPageControllerTest < ActionController::TestCase


  def setup
    @request.host = "localhost"
  end

  def test_show
    page = DiscussionPage.where(public: true).first
    get :show, id: page.id
    assert_response :success
  end

end
