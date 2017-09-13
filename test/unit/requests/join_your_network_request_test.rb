require 'test_helper'

class JoinYourNetworkRequestTest < ActiveSupport::TestCase
  def setup
    @user    = FactoryGirl.create(:user)
    @group   = FactoryGirl.create(:group)
    @network = FactoryGirl.create(:network)
  end

  def test_valid_request
    @group.add_user! @user
    assert_difference 'Request.count' do
      RequestToJoinYourNetwork.create! created_by: @user,
                                       recipient: @network,
                                       requestable: @group
    end
  end

  def test_no_duplicate_membership
    @group.add_user! @user
    @network.add_group! @group
    assert_raises ActiveRecord::RecordInvalid, 'duplicate membership not allowed' do
      RequestToJoinYourNetwork.create! created_by: @user,
                                       recipient: @network,
                                       requestable: @group
    end
  end

  # currently failing due to the permissions hack that allows all.
  def test_only_member_may_request
    @network.add_user! @user
    assert_raises ActiveRecord::RecordInvalid, 'PERMISSIONS DISABLED: non member is able to request membership for a group' do
      RequestToJoinYourNetwork.create! created_by: @user,
                                       recipient: @network,
                                       requestable: @group
    end
  end

  def test_valid_approval
    @network.add_user! @user
    inviter = FactoryGirl.create(:user)
    @group.add_user! inviter
    req = RequestToJoinYourNetwork.create! created_by: inviter,
                                           recipient: @network,
                                           requestable: @group
    assert_nothing_raised do
      req.approve_by!(@user)
    end
    assert @network.groups(true).include?(@group)
  end
end
