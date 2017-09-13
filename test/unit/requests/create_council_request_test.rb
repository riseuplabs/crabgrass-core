require 'test_helper'

class CreateCouncilRequestTest < ActiveSupport::TestCase
  def setup
    @requesting_user = FactoryGirl.create(:user)
    @accepting_user = FactoryGirl.create(:user)
    @group = FactoryGirl.create :group
    @group.add_user! @requesting_user
    @group.add_user! @accepting_user

    # tweak group and memberships, so both users are long-term members
    @group.update_attribute :created_at, 2.weeks.ago
    @group.memberships.each do |m|
      m.update_attribute :created_at, 10.years.ago
    end

    # this user is *not* a long-term member
    @new_user = FactoryGirl.create(:user)
    @group.add_user!(@new_user)

    @request = RequestToCreateCouncil.create!(
      created_by: @requesting_user,
      recipient: @group,
      requestable: @group
    )
  end

  # just to check that the setup() works correctly.
  def test_valid
    assert true
  end

  def test_may_approve
    assert(!@request.may_approve?(@requesting_user),
           'Expected the requesting user not to be able to approve this request')
    assert(!@request.may_approve?(@new_user),
           'Expected a new user not to be able to approve this request')
    assert(@request.may_approve?(@accepting_user),
           'Expected a long-term member to be able to approve this request')
  end

  def test_approve_creates_council
    assert_difference 'Group::Council.count' do
      @request.mark! :approve, @accepting_user
    end
  end

  def test_approve_adds_accepting_user_to_council
    @request.mark! :approve, @accepting_user
    assert @accepting_user.reload.member_of? @group.reload.council
  end

  def test_approve_adds_requesting_user_to_council
    @request.mark! :approve, @accepting_user
    assert @requesting_user.reload.member_of? @group.reload.council
  end

  def test_approve_doesnt_add_more_users_to_council
    @request.mark! :approve, @accepting_user
    assert_equal 2, @group.reload.council.memberships.count
  end
end
