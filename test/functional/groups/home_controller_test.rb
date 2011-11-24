require File.dirname(__FILE__) + '/../../test_helper'

class Groups::HomeControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user!(@user)
    @pub = @group.profiles.public.create_wiki
    @priv = @group.profiles.private.create_wiki
    Group.stubs(:find_by_name).with(@group.to_param).returns(@group)
  end

  def test_show
    login_as @user
    assert_permission :may_show_group_home? do
      get :show, :id => @group.to_param
    end
    assert_response :success
    assert_equal @pub, assigns('public_wiki')
    assert_equal @priv, assigns('private_wiki')
    assert_equal @priv, assigns('wiki')
  end

  def test_show_after_editing_public
    login_as @user
    @request.env['HTTP_REFERER'] = edit_group_wiki_url(@group, @pub)
    assert_permission :may_show_group_home? do
      get :show, :id => @group.to_param
    end
    assert_response :success
    assert_equal @pub, assigns('public_wiki')
    assert_equal @priv, assigns('private_wiki')
    assert_equal @pub, assigns('wiki')
  end

  def test_show_public
    @group.grant! :public, :view
    assert_permission :may_show_group_home? do
      get :show, :id => @group.to_param
    end
    assert_response :success
    assert_equal @pub, assigns('wiki')
    assert_nil assigns('private_wiki')
    assert_nil assigns('public_wiki')
  end

  def test_may_not_show
    assert_permission :may_show_group_home?, false do
      get :show, :id => @group.to_param
    end
  end

end
