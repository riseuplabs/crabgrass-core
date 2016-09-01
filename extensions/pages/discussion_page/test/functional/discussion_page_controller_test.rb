require 'test_helper'

class DiscussionPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, 'user/participations'

  def setup
    @request.host = "localhost"
  end

  def test_show
    page = DiscussionPage.find :first, conditions: {public: true}
    get :show, id: page.id
    assert_response :success
  end

end
