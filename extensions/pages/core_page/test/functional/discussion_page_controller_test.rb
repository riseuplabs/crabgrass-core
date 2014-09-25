require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class DiscussionPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @request.host = "localhost"
  end

  def test_show
    page = DiscussionPage.find :first, :conditions => {:public => true}
    get :show, :page_id => page.id
    assert_response :success
  end

end
