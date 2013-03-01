require File.dirname(__FILE__) + '/../test_helper'

class GroupModelTest < ActiveSupport::TestCase

  def setup
    Conf.load_defaults
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
    Conf.councils = false
    assert !Group.can_have_council?
    assert Group.can_have_committees?
  end

  def test_committees_can_be_disabled
    Conf.committees = false
    assert !Group.can_have_committees?
    assert !Group.can_have_council?
  end

  def test_network_can_have_council
    assert Network.can_have_council?
    assert Network.can_have_committees?
  end

  def test_council_can_not_have_council
    assert !Council.can_have_council?
    assert !Council.can_have_committees?
  end

  def test_committees_can_not_have_council
    assert !Committee.can_have_council?
    assert !Committee.can_have_committees?
  end

end
