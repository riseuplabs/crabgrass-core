require 'test_helper'

class Group::HomeControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user!(@user)
    @pub = @group.profiles.public.create_wiki body: 'hello'
    @priv = @group.profiles.private.create_wiki body: 'pssst'
  end

  def test_show
    login_as @user
    assert_permission :may_show_group? do
      get :show, group_id: @group.to_param
    end
    assert_response :success
    assert_equal @pub, assigns('public_wiki')
    assert_equal @priv, assigns('private_wiki')
    last_visit = @group.memberships.where(user_id: @user).pluck(:visited_at).first
    assert (last_visit > 1.minute.ago), 'visited_at should be set'
  end

  def test_show_public
    assert_permission :may_show_group? do
      get :show, group_id: 'animals'
    end
    assert_response :success
    assert assigns('group').present?
  end

  ##
  ## no longer applicable
  ##
  # def test_show_after_editing_public
  #   login_as @user
  #   @request.env['HTTP_REFERER'] = edit_group_wiki_url(@group, @pub)
  #   assert_permission :may_show_group? do
  #     get :show, :group_id => @group.to_param, :wiki_id => @pub.id
  #   end
  #   assert_response :success
  #   assert_equal @pub, assigns('public_wiki')
  #   assert_equal @priv, assigns('private_wiki')
  #   assert_equal @pub, assigns('wiki')
  # end

  def test_show_public_only
    login_as FactoryBot.create(:user)
    @group.grant_access! public: :view
    assert_permission :may_show_group? do
      get :show, group_id: @group.to_param
    end
    assert_response :success
    assert_nil assigns('private_wiki')
    assert_equal @pub, assigns('public_wiki')
  end

  def test_may_not_show
    login_as FactoryBot.create(:user)
    @group.revoke_access! public: :view
    assert_permission :may_show_group?, false do
      assert_not_found do
        get :show, group_id: @group.to_param
      end
    end
  end
end
