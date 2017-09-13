require 'test_helper'

class RequestNoticeTest < ActiveSupport::TestCase
  def setup
    @user_in_network  = FactoryGirl.create(:user)
    @user_in_group_1  = FactoryGirl.create(:user)
    @user_in_group_2  = FactoryGirl.create(:user)
    @user_council     = FactoryGirl.create(:user)
    @group            = FactoryGirl.create(:group)
    @council          = FactoryGirl.create(:council)
    @network          = FactoryGirl.create(:network)

    @group.add_user! @user_in_group_1
    @group.add_user! @user_in_group_2
    @council.add_user! @user_council
    @network.add_user! @user_in_network
  end

  def test_request_for_group_without_council_notifies_all_members
    req = RequestToJoinOurNetwork.create(created_by: @user_in_network,
                                         recipient: @group, requestable: @network)

    assert_nil @group.council
    assert_difference('Notice::RequestNotice.count', 2) do
      Notice::RequestNotice.create! req
    end
  end

  def test_request_for_group_with_council_notifies_only_council_members
    req = RequestToJoinOurNetwork.create(created_by: @user_in_network,
                                         recipient: @group, requestable: @network)

    @group.council = @council
    @group.save
    assert_instance_of Group::Council, @group.council
    assert_difference 'Notice::RequestNotice.count' do
      Notice::RequestNotice.create! req
    end
  end

  def test_friend_request_notice
    u1 = @user_in_group_1
    u2 = @user_in_group_2
    req = RequestToFriend.create! created_by: u1,
                                  recipient: u2,
                                  message: 'hi, lets be friends'
    Notice::RequestNotice.create request: req
    assert_equal req, req.notices.first.request
    assert_difference 'Notice.count', -1 do
      req.destroy
    end
  end
end
