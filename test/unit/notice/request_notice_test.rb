require File.dirname(__FILE__) + '/../../test_helper'

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
    assert_difference('RequestNotice.count', 2) do
      RequestNotice.create! req
    end
  end

  def test_request_for_group_with_council_notifies_only_council_members
    req = RequestToJoinOurNetwork.create(created_by: @user_in_network,
      recipient: @group, requestable: @network)

    @group.council = @council
    @group.save
    assert_instance_of Council, @group.council
    assert_difference 'RequestNotice.count' do
      RequestNotice.create! req
    end
  end

end
