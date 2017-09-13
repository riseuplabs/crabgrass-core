require 'test_helper'

class Group::ModelTest < ActiveSupport::TestCase
  def setup
    @group = FactoryGirl.build(:group)
  end

  def test_recent_is_false_for_old_group
    @group.created_at = 1.days.ago
    assert @group.recent?
  end

  def test_recent_is_true_for_new_group
    @group.created_at = 10.days.ago
    assert !@group.recent?
  end

  def test_single_user_is_true_with_one_user
    @group.save!
    @group.add_user!(FactoryGirl.create(:user))
    assert @group.single_user?
  end

  def test_single_user_is_false_with_two_users
    @group.save!
    2.times { @group.add_user!(FactoryGirl.create(:user)) }
    assert !@group.single_user?
  end

  def test_group_can_have_council
    assert Group.can_have_council?
    assert Group.can_have_committees?
  end

  def test_councils_can_be_disabled
    Conf.stub :councils, false do
      assert !Group.can_have_council?
      assert Group.can_have_committees?
    end
  end

  def test_committees_can_be_disabled
    Conf.stub :committees, false do
      assert !Group.can_have_committees?
      assert !Group.can_have_council?
    end
  end

  def test_network_can_have_council
    assert Group::Network.can_have_council?
    assert Group::Network.can_have_committees?
  end

  def test_council_can_not_have_council
    assert !Group::Council.can_have_council?
    assert !Group::Council.can_have_committees?
  end

  def test_committees_can_not_have_council
    assert !Group::Committee.can_have_council?
    assert !Group::Committee.can_have_committees?
  end
end
