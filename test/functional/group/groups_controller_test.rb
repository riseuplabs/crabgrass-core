require 'test_helper'

class Group::GroupsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
  end

  def test_new_group_requires_login
    assert_login_required do
      get :new
    end
  end

  def test_choose_group_type
    login_as @user
    assert_permission :may_create_group? do
      get :new
    end
    assert_response :success
    assert_template :_choose_group_type
  end

  def test_new_committee
    login_as @user
    assert_permission :may_create_group? do
      get :new, type: 'committee'
    end
    assert_response :success
    assert_template :_choose_parent_group
  end

  def test_new_council
    login_as @user
    assert_permission :may_create_group? do
      get :new, type: 'council'
    end
    assert_response :success
    assert_template :_choose_parent_group
  end

  def test_new_group
    login_as @user
    assert_permission :may_create_group? do
      get :new, type: 'group'
    end
    assert_response :success
    assert_template 'group/structures/_new_form'
  end

  def test_new_network
    login_as @user
    assert_permission :may_create_group? do
      get :new, type: 'network'
    end
    assert_response :success
    assert_template 'group/structures/_new_form'
  end

  def test_create_group
    login_as @user
    assert_difference 'Group.count' do
      assert_permission :may_create_group? do
        post :create, group: { name: 'test-create-group', full_name: 'Group for Testing Group Creation!' }
      end
      assert_response :redirect
      group = Group.find_by_name 'test-create-group'
      assert_redirected_to group_url(group)
    end
  end

  def test_create_no_group_without_name
    login_as @user
    assert_no_difference 'Group.count' do
      post :create, group: { name: '' }
      assert_error_message
    end
  end

  def test_create_no_group_with_duplicate_name
    FactoryGirl.create(:group, name: 'flowers')
    login_as @user
    assert_no_difference 'Group.count' do
      post :create, group: { name: 'flowers' }
      assert_error_message
    end
  end

  def test_create_network_with_group_member
    group = FactoryGirl.create(:group, name: 'pine')
    group.add_user! @user
    login_as @user
    assert_difference 'Group::Network.count' do
      post :create, type: 'network',
                    group: { name: 'trees', initial_member_group: group.name }
    end
    network = Group::Network.last
    assert !@user.direct_member_of?(network),
           'user should not become member of their groups new network'
    assert @user.may?(:admin, network),
           'user should be able to admin network through group'
  end

  def test_create_no_network_with_network_member
    network = FactoryGirl.create(:network, name: 'flowers')
    network.add_user! @user
    login_as @user
    assert_no_difference 'Group.count' do
      post :create, type: 'network',
                    group: { name: 'trees', initial_member_group: network.name }
      assert_error_message
    end
  end

  def test_destroy_group
    user = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)
    group.add_user!(user)
    login_as user
    assert_difference 'Group.count', -1 do
      assert_permission :may_destroy_group? do
        delete :destroy, id: group.to_param
      end
    end
  end
end
