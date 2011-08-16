require File.dirname(__FILE__) + '/../../test_helper'

class Groups::InvitesControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user! @user
  end


  def test_index
    login_as @user
    assert_permission :may_list_groups_invites? do
      get :index, :group_id => @group.to_param
    end
    assert_response :success
  end

  def test_new
    login_as @user
    assert_permission :may_create_groups_invite? do
      get :new, :group_id => @group.to_param
    end
    assert_response :success
  end

  def test_create
    login_as @user
    recipient = User.make
    assert_permission :may_create_groups_invite? do
      assert_difference '@group.invites.count' do
        get :create, :group_id => @group.to_param,
         :recipients => recipient.name
      end
    end
    assert_response :redirect
    assert_redirected_to :action => :index
  end

  def test_update
    login_as @user
    recipient = User.make
    invite = RequestToJoinUs.create :created_by => @user,
      :recipient => recipient, :requestable => @group
    assert_permission :may_edit_groups_invite? do
      get :update, :group_id => @group.to_param,
        :id => invite.id
    end
  end

  def test_destroy
    login_as @user
    recipient = User.make
    invite = RequestToJoinUs.create :created_by => @user,
      :recipient => recipient, :requestable => @group
    assert_permission :may_destroy_groups_invite? do
      assert_difference '@group.invites.count', -1 do
        delete :destroy, :group_id => @group.to_param,
         :id => invite.id
      end
    end
    assert_response :success
  end
end
