require 'test_helper'

class Groups::PagesControllerTest < ActionController::TestCase
  fixtures :all

  def test_index
    user = users(:penguin)
    group = groups(:rainbow)
    login_as user
    assert_permission :may_show_group? do
      get :index, group_id: group
    end
    assert_response :success
    assert assigns('pages').any?
    assert assigns('pages').all?{|p| p.public? || user.may?(:view, p)}
  end
end
