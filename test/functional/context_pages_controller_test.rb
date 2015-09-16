require 'test_helper'

class ContextPagesControllerTest < ActionController::TestCase
  fixtures :all

  def test_group_page
    login_as users(:blue)
    get :show, context_id: 'rainbow', id: 'rainbow_page'
    assert_response :success
    assert_equal pages(:rainbow_page), assigns(:page)
    assert_equal groups(:rainbow), assigns(:group)
  end

  def test_user_page
    login_as users(:blue)
    get :show, context_id: 'blue', id: 'blue_page'
    assert_response :success
    assert_equal pages(:blue_page), assigns(:page)
    assert_equal users(:blue), assigns(:user)
  end

end
