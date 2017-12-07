require 'test_helper'

class Group::InvitesControllerTest < ActionController::TestCase
  def setup
    @user                          = FactoryBot.create(:user)
    @user_not_in_group             = FactoryBot.create(:user)
    @user_not_in_network           = FactoryBot.create(:user)
    @user_council                  = FactoryBot.create(:user)
    @group                         = FactoryBot.create(:group)
    @council                       = FactoryBot.create(:council)
    @network                       = FactoryBot.create(:network)
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
    recipient = FactoryBot.create(:user)
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
    email =  'test@mail.me'
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
    recipient = FactoryBot.create(:user)

    assert_notice_for(recipient) do
      post :create, group_id: @group.to_param, recipients: recipient.name
    end
  end

  def test_invite_to_join_us_notifies_all_valid_recipients
    login_as @user
    recipient = FactoryBot.create(:user)

    # As @user already member of a group it should not be notified
    assert_notice_for recipient, @user_not_in_group do
      post :create, group_id: @group.to_param,
                    recipients: "#{recipient.name}, #{@user.name}, #{@user_not_in_group.name}"
    end
  end

  def test_invite_group_to_network_notifies_all_group_members_if_no_council
    login_as @user

    # @group has only two members, no council
    assert_nil @group.council
    assert_notice_for @user, @user_not_in_network do
      post :create, group_id: @network.to_param, recipients: @group.name
    end

    notice = Notice::RequestNotice.last(2)
    assert_equal 'request_to_join_our_network', notice.first.data[:title]
    assert_equal 'request_to_join_our_network', notice.last.data[:title]
  end

  def test_invite_group_to_network_notifies_only_council_if_it_presents
    login_as @user

    # @group has a council with one member and two other members
    @group.council = @council
    @group.save
    assert_instance_of Group::Council, @group.council
    assert_notice_for @user_council do
      post :create, group_id: @network.to_param, recipients: @group.name
    end
  end

  def test_invite_by_email_does_not_notify_internally
    email =  'test@mail.me'
    login_as @user
    assert_no_notice do
      post :create, group_id: @group.to_param, recipients: email
    end
  end

  protected

  def assert_no_notice(&block)
    assert_notice_for &block
  end

  def assert_notice_for(*recipients, &block)
    assert_difference 'Notice::RequestNotice.count', recipients.count, &block

    notices = Notice::RequestNotice.last(recipients.count)
    notices.each_with_index do |notice, i|
      assert_equal recipients[i].id, notice.user_id
    end
  end
end
