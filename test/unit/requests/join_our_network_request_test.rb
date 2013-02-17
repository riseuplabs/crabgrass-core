require File.dirname(__FILE__) + '/../test_helper'

class JoinOurNetworkRequestTest < ActiveSupport::TestCase

  def setup
    @user    = FactoryGirl.create(:user)
    @group   = FactoryGirl.create(:group)
    @network = FactoryGirl.create(:network)
  end

  def test_valid_request
    @network.add_user! @user
    assert_difference 'Request.count' do
      RequestToJoinOurNetwork.create! :created_by => @user,
        :recipient => @group,
        :requestable => @network
    end
  end

  def test_no_duplicate_membership
    @network.add_user! @user
    @network.add_group! @group
    assert_raises ActiveRecord::RecordInvalid, 'duplicate membership not allowed' do
      RequestToJoinOurNetwork.create! :created_by => @user,
        :recipient => @group,
        :requestable => @network
    end
  end

  # currently failing due to the permissions hack that allows all.
  def test_only_member_may_invite
    @group.add_user! @user
    assert_raises ActiveRecord::RecordInvalid, 'PERMISSIONS DISABLED: non member is able to invite to network' do
      RequestToJoinOurNetwork.create! :created_by => @user,
        :recipient => @group,
        :requestable => @network
    end
  end

  def test_valid_approval
    @group.add_user! @user
    inviter = FactoryGirl.create(:user)
    @network.add_user! inviter
    req = RequestToJoinOurNetwork.create! :created_by => inviter,
      :recipient => @group,
      :requestable => @network
    assert !@network.groups(true).include?(@group)
    assert_nothing_raised do
      req.approve_by!(@user)
    end
    assert @network.groups(true).include?(@group)
  end

end

