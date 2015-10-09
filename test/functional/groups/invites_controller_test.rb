require File.dirname(__FILE__) + '/../../test_helper'

class Groups::InvitesControllerTest < ActionController::TestCase

  def setup
    @user                          = FactoryGirl.create(:user)
    @user_not_in_group             = FactoryGirl.create(:user)
    @user_not_in_network           = FactoryGirl.create(:user)
    @user_council                  = FactoryGirl.create(:user)
    @group                         = FactoryGirl.create(:group)
    @council                       = FactoryGirl.create(:council)
    @network                       = FactoryGirl.create(:network)
    @council.add_user! @user_council
    @group.add_user! @user
    @group.add_user! @user_not_in_network
    @network.add_user! @user
    @network.add_user! @user_not_in_group
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
        post :create, group_id: @group.to_param,
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
        post :create, group_id: @network.to_param,
          recipients: @group.name
      end
    end
    assert_response :redirect
    assert_redirected_to action: :new
  end

  def test_create_email_invite
    email =  "test@mail.me"
    login_as @user
    assert_permission :may_admin_group? do
      assert_difference 'RequestToJoinUsViaEmail.count' do
        post :create, group_id: @group.to_param,
          recipients: email
      end
    end
    assert_response :redirect
    assert_redirected_to action: :new
    assert req = RequestToJoinUsViaEmail.last
    assert_equal @group, req.requestable
    assert_equal email, req.email
    assert req.valid?
  end

  def test_invite_to_join_us_notifies_recipient
    login_as @user
    recipient = FactoryGirl.create(:user)

    assert_difference 'RequestNotice.count' do
      post :create, group_id: @group.to_param, recipients: recipient.name
    end

    notice = RequestNotice.last
    assert_equal recipient.id, notice.user_id
    assert_equal 'request_to_join_us', notice.data[:title]
  end

  def test_invite_to_join_us_notifies_all_valid_recipients
    login_as @user
    recipient = FactoryGirl.create(:user)

    # As @user already member of a group it should not be notified
    assert_difference('RequestNotice.count', 2) do
      post :create, group_id: @group.to_param,
        recipients: "#{recipient.name}, #{@user.name}, #{@user_not_in_group.name}"
    end

    notice = RequestNotice.last(2)
    assert_equal recipient.id, notice.first.user_id
    assert_equal @user_not_in_group.id, notice.last.user_id
    assert_equal 'request_to_join_us', notice.first.data[:title]
    assert_equal 'request_to_join_us', notice.last.data[:title]
  end

  def test_invite_group_to_network_notifies_all_group_members_if_no_council
    login_as @user

    # @group has only two members, no council
    assert_nil @group.council
    assert_difference('RequestNotice.count', 2) do
      post :create, group_id: @network.to_param, recipients: @group.name
    end

    notice = RequestNotice.last(2)
    assert_equal @user.id, notice.first.user_id
    assert_equal @user_not_in_network.id, notice.last.user_id
    assert_equal 'request_to_join_our_network', notice.first.data[:title]
    assert_equal 'request_to_join_our_network', notice.last.data[:title]
  end

  def test_invite_group_to_network_notifies_only_council_if_it_presents
    login_as @user

    # @group has a council with one member and two other members
    @group.council = @council
    @group.save
    assert_instance_of Group::Council, @group.council
    assert_difference 'RequestNotice.count' do
      post :create, group_id: @network.to_param, recipients: @group.name
    end

    notice = RequestNotice.last
    assert_equal @user_council.id, notice.user_id
    assert_equal 'request_to_join_our_network', notice.data[:title]
  end

  def test_invite_by_email_does_not_notify_internally
    email =  "test@mail.me"
    login_as @user
    assert_no_difference 'RequestNotice.count' do
      post :create, group_id: @group.to_param, recipients: email
    end
  end

end
