require 'test_helper'

class Group::GroupsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
  end

  def test_new_group_requires_login
    get :new
    assert_login_required
  end

  def test_choose_group_type
    login_as @user
    get :new
    assert_response :success
    assert_template :_choose_group_type
  end

  def test_new_committee
    login_as @user
    get :new, params: { type: 'committee' }
    assert_response :success
    assert_template :_choose_parent_group
  end

  def test_new_council
    login_as @user
    get :new, params: { type: 'council' }
    assert_response :success
    assert_template :_choose_parent_group
  end

  def test_new_group
    login_as @user
    get :new, params: { type: 'group' }
    assert_response :success
    assert_template 'group/structures/_new_form'
  end

  def test_new_network
    login_as @user
    get :new, params: { type: 'network' }
    assert_response :success
    assert_template 'group/structures/_new_form'
  end

  def test_create_group
    login_as @user
    assert_difference 'Group.count' do
      post :create, params: { group: { name: 'test-create-group', full_name: 'Group for Testing Group Creation!' } }
      assert_response :redirect
      group = Group.find_by_name 'test-create-group'
      assert_redirected_to group_url(group)
    end
  end

  def test_create_no_group_without_name
    login_as @user
    assert_no_difference 'Group.count' do
      post :create, params: { group: { name: '' } }
      assert_error_message
    end
  end

  def test_create_no_group_with_duplicate_name
    FactoryBot.create(:group, name: 'flowers')
    login_as @user
    assert_no_difference 'Group.count' do
      post :create, params: { group: { name: 'flowers' } }
      assert_error_message
    end
  end

  def test_create_network_with_group_member
    group = FactoryBot.create(:group, name: 'pine')
    group.add_user! @user
    login_as @user
    assert_difference 'Group::Network.count' do
      post :create, params: { type: 'network', group: { name: 'trees', initial_member_group: group.name } }
    end
    network = Group::Network.last
    assert !@user.direct_member_of?(network),
           'user should not become member of their groups new network'
    assert @user.may?(:admin, network),
           'user should be able to admin network through group'
  end

  def test_create_no_network_with_network_member
    network = FactoryBot.create(:network, name: 'flowers')
    network.add_user! @user
    login_as @user
    assert_no_difference 'Group.count' do
      post :create, params: { type: 'network', group: { name: 'trees', initial_member_group: network.name } }
      assert_error_message
    end
  end

  def test_destroy_group
    user = FactoryBot.create(:user)
    group = FactoryBot.create(:group)
    group.add_user!(user)
    login_as user
    assert_difference 'Group.count', -1 do
      delete :destroy, params: { id: group.to_param }
    end
  end

  def test_destroy_group_not_allowed
    user = FactoryBot.create(:user)
    group = FactoryBot.create(:group)
    login_as user
    delete :destroy, params: { id: group.to_param }
    assert_not_found
  end

end
