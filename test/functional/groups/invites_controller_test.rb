require File.dirname(__FILE__) + '/../../test_helper'

class Groups::InvitesControllerTest < ActionController::TestCase

  def setup
    @user     = FactoryGirl.create(:user)
    @group    = FactoryGirl.create(:group)
    @network  = FactoryGirl.create(:network)
    @group.add_user! @user
    @network.add_user! @user
  end


  def test_new
    login_as @user
    assert_permission :may_admin_group? do
      get :new, group_id: @group.to_param
    end
    assert_response :success
  end

  def test_create
    login_as @user
    recipient = FactoryGirl.create(:user)
    assert_permission :may_admin_group? do
      assert_difference 'RequestToJoinUs.count' do
        get :create, group_id: @group.to_param,
         recipients: recipient.name
      end
    end
    assert_response :redirect
    assert_redirected_to action: :new
    assert req = RequestToJoinUs.last
    assert_equal @group, req.requestable
    assert_equal recipient, req.recipient
    assert req.valid?
  end

  def test_invite_group_to_network
    login_as @user
    assert_permission :may_admin_group? do
      assert_difference 'RequestToJoinOurNetwork.count' do
        get :create, group_id: @network.to_param,
          recipients: @group.name
      end
    end
    assert_response :redirect
    assert_redirected_to action: :new
  end

end
