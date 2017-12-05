require 'test_helper'

class RateManyPageControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create :user
    @page = FactoryBot.create :rate_many_page, title: 'Show this page!', created_by: @user
  end

  def test_show
    login_as @user

    get :show, id: @page.id
    assert_response :success
  end
end
